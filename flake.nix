{
  description = "overleaf-sync - Sync your local files with Overleaf";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      python = pkgs.python3;

      yaspin-2 = python.pkgs.buildPythonPackage rec {
        pname = "yaspin";
        version = "2.5.0";
        format = "pyproject";
        src = python.pkgs.fetchPypi {
          inherit pname version;
          sha256 = "f96ab3b5c42e1eaa6af3193508082309d9dc43f6963339f9aa606003ee8d7e63";
        };
        nativeBuildInputs = with python.pkgs; [ poetry-core pythonRelaxDepsHook ];
        pythonRelaxDeps = [ "termcolor" ];
        propagatedBuildInputs = with python.pkgs; [ termcolor ];
        doCheck = false;
      };

      overleaf-sync = python.pkgs.buildPythonApplication rec {
        pname = "overleaf-sync";
        version = "1.2.0";
        format = "setuptools";

        src = python.pkgs.fetchPypi {
          inherit pname version;
          sha256 = "94ace0ffc902dadc31934dedc5f11cbbbd5b58efb85bb1fce10020d4eca7a3ec";
        };

        propagatedBuildInputs = with python.pkgs; [
          requests
          beautifulsoup4
          python-dateutil
          click
          websocket-client
          yaspin-2
        ];

        postPatch = ''
          # relax strict version pins in setup.cfg/setup.py
          sed -i \
            -e 's/beautifulsoup4 == 4\.11\.1/beautifulsoup4/' \
            -e 's/yaspin == 2\.\*/yaspin/' \
            -e 's/python-dateutil~=2\.8\.1/python-dateutil/' \
            -e 's/socketIO-client == 0\.5\.7\.2/websocket-client/' \
            -e 's/PySide6 == 6\.\*//' \
            setup.cfg setup.py 2>/dev/null || true

          # Store the auth cookie in ~/.olauth so it is found from any directory.
          sed -i 's|default=".olauth"|default=os.path.expanduser("~/.olauth")|g' olsync/olsync.py

          # Replace the broken QtWebEngine login with a plain requests-based
          # CLI login. PySide6/Chromium crashes with SIGSEGV under Nix due to
          # V8 JIT mprotect being blocked; requests avoids the browser entirely.
          #
          # Credentials are collected via prompt_credentials() which olsync.py
          # calls BEFORE execute_action() starts the yaspin spinner — the spinner
          # hijacks the terminal so input() is unusable inside it.
          cat > olsync/olbrowserlogin.py << 'PYEOF'
"""Ol Browser Login Utility - CLI fallback (no QtWebEngine)"""

import getpass
import webbrowser
import requests
from bs4 import BeautifulSoup

LOGIN_URL = "https://www.overleaf.com/login"
PROJECT_URL = "https://www.overleaf.com/project"
COOKIE_NAMES = ["overleaf_session2", "GCLB"]

_credentials = {}  # set by prompt_credentials(), consumed by login()


def prompt_credentials():
    """Collect login info before the yaspin spinner starts."""
    print("Overleaf login")
    print("  [1] Email + password")
    print("  [2] Google / SSO (paste cookies from browser)")
    choice = input("Choice [1/2]: ").strip()
    _credentials["method"] = "oauth" if choice == "2" else "password"

    if _credentials["method"] == "password":
        _credentials["email"] = input("Email: ")
        _credentials["password"] = getpass.getpass("Password: ")
    else:
        print()
        webbrowser.open(PROJECT_URL)
        print("Opening https://www.overleaf.com/project in your browser.")
        print("Log in there (via Google or SSO), then open DevTools (F12).")
        print()
        print("Go to: Application → Cookies → https://www.overleaf.com")
        print("Copy the value of overleaf_session2 (starts with s:...).")
        print("Also copy GCLB if present (press Enter to skip).")
        print()
        _credentials["session2"] = input("overleaf_session2: ").strip()
        _credentials["gclb"] = input("GCLB (Enter to skip): ").strip()


BROWSER_UA = (
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
)


def _session():
    s = requests.Session()
    s.headers.update({"User-Agent": BROWSER_UA})
    return s


def login():
    if _credentials.get("method") == "oauth":
        session2 = _credentials["session2"]
        gclb = _credentials.get("gclb", "")

        # Send cookies as a raw header string to avoid Python cookie encoding
        # issues with the "s:" prefix in Overleaf session values.
        cookie_str = f"overleaf_session2={session2}"
        if gclb:
            cookie_str += f"; GCLB={gclb}"

        s = _session()
        test = s.get(PROJECT_URL, headers={"Cookie": cookie_str})
        csrf_tag = BeautifulSoup(test.content, "html.parser").find(
            "meta", {"name": "ol-csrfToken"}
        )
        if csrf_tag is None:
            print(f"\nCookie verification failed (ended up at: {test.url})")
            print("The session may be expired or IP-restricted.")
            return None

        cookies = {"overleaf_session2": session2}
        if gclb:
            cookies["GCLB"] = gclb
        return {"cookie": cookies, "csrf": csrf_tag.get("content")}

    # Email + password flow
    session = _session()
    resp = session.get(LOGIN_URL)
    resp.raise_for_status()
    csrf_tag = BeautifulSoup(resp.content, "html.parser").find("input", {"name": "_csrf"})
    if csrf_tag is None:
        print("Could not find CSRF token on login page.")
        return None

    login_resp = session.post(
        LOGIN_URL,
        json={
            "_csrf": csrf_tag.get("value"),
            "email": _credentials.get("email", ""),
            "password": _credentials.get("password", ""),
        },
    )
    if login_resp.status_code != 200:
        print(f"Login request failed with status {login_resp.status_code}.")
        return None

    projects_resp = session.get(PROJECT_URL)
    new_csrf_tag = BeautifulSoup(projects_resp.content, "html.parser").find(
        "meta", {"name": "ol-csrfToken"}
    )
    if new_csrf_tag is None:
        print("Login failed: wrong credentials or captcha triggered.")
        return None

    cookies = {name: session.cookies[name] for name in COOKIE_NAMES if name in session.cookies}
    if "overleaf_session2" not in cookies:
        print("Login failed: session cookie not received.")
        return None

    return {"cookie": cookies, "csrf": new_csrf_tag.get("content")}
PYEOF

          # Rewrite olclient.py to send a browser User-Agent and raw Cookie
          # header string. Overleaf rejects python-requests UA, and Python's
          # http.cookiejar can mis-encode cookie values containing "s:".
          cat > olsync/olclient.py << 'PYEOF'
"""Overleaf Client"""

import requests as reqs
from bs4 import BeautifulSoup
import json
import uuid
import websocket

LOGIN_URL = "https://www.overleaf.com/login"
PROJECT_URL = "https://www.overleaf.com/project"
DASHBOARD_URL = "https://www.overleaf.com/project"
PROJECT_PAGE_URL = "https://www.overleaf.com/project/{}"
SOCKET_ID_URL = "https://www.overleaf.com/socket.io/1/?projectId={}"
SOCKET_URL = "wss://www.overleaf.com/socket.io/1/websocket/{}?projectId={}"
DOWNLOAD_URL = "https://www.overleaf.com/project/{}/download/zip"
UPLOAD_URL = "https://www.overleaf.com/project/{}/upload"
FOLDER_URL = "https://www.overleaf.com/project/{}/folder"
DELETE_URL = "https://www.overleaf.com/project/{}/doc/{}"
COMPILE_URL = "https://www.overleaf.com/project/{}/compile?enable_pdf_caching=true"
BASE_URL = "https://www.overleaf.com"
PATH_SEP = "/"

BROWSER_UA = (
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
)


class OverleafClient(object):

    @staticmethod
    def filter_projects(json_content, more_attrs=None):
        more_attrs = more_attrs or {}
        for p in json_content:
            if not p.get("archived") and not p.get("trashed"):
                if all(p.get(k) == v for k, v in more_attrs.items()):
                    yield p

    def __init__(self, cookie=None, csrf=None):
        self._cookie = cookie
        self._csrf = csrf
        # Build raw cookie string to avoid Python http.cookiejar encoding issues
        if isinstance(cookie, dict):
            self._cookie_str = "; ".join(f"{k}={v}" for k, v in cookie.items())
        else:
            self._cookie_str = "; ".join(f"{c.name}={c.value}" for c in (cookie or []))

    def _h(self, extra=None):
        """Headers with browser UA and raw Cookie string."""
        h = {"User-Agent": BROWSER_UA, "Cookie": self._cookie_str}
        if extra:
            h.update(extra)
        return h

    def login(self, username, password):
        """Deprecated – kept for API compatibility."""
        get_login = reqs.get(LOGIN_URL)
        self._csrf = BeautifulSoup(get_login.content, 'html.parser').find(
            'input', {'name': '_csrf'}).get('value')
        login_json = {"_csrf": self._csrf, "email": username, "password": password}
        post_login = reqs.post(LOGIN_URL, json=login_json, cookies=get_login.cookies)
        if post_login.status_code == 200 and get_login.cookies["overleaf_session2"] != post_login.cookies["overleaf_session2"]:
            self._cookie = post_login.cookies
            self._cookie['GCLB'] = get_login.cookies['GCLB']
            projects_page = reqs.get(PROJECT_URL, cookies=self._cookie)
            self._csrf = BeautifulSoup(projects_page.content, 'html.parser').find('meta', {'name': 'ol-csrfToken'}).get('content')
            return {"cookie": self._cookie, "csrf": self._csrf}

    def _parse_projects(self, page_content):
        soup = BeautifulSoup(page_content, 'html.parser')
        meta = soup.find('meta', {'name': 'ol-prefetchedProjectsBlob'})
        if meta:
            data = json.loads(meta.get('content'))
            if 'projects' in data:
                return data['projects']
        meta = soup.find('meta', {'name': 'ol-projects'})
        if meta:
            return json.loads(meta.get('content'))
        raise Exception("Cannot find projects data — session may have expired.")

    def all_projects(self):
        page = reqs.get(PROJECT_URL, headers=self._h())
        if not page.ok:
            raise Exception(f"Failed to fetch projects: HTTP {page.status_code}")
        return list(OverleafClient.filter_projects(self._parse_projects(page.content)))

    def get_project(self, project_name):
        page = reqs.get(PROJECT_URL, headers=self._h())
        return next(OverleafClient.filter_projects(
            self._parse_projects(page.content), {"name": project_name}), None)

    def download_project(self, project_id):
        r = reqs.get(DOWNLOAD_URL.format(project_id), stream=True, headers=self._h())
        return r.content

    def create_folder(self, project_id, parent_folder_id, folder_name):
        params = {"parent_folder_id": parent_folder_id, "name": folder_name}
        extra = {"X-Csrf-Token": self._csrf}
        r = reqs.post(FOLDER_URL.format(project_id), headers=self._h(extra), json=params)
        if r.ok:
            return json.loads(r.content)
        elif r.status_code == str(400):
            return
        else:
            raise reqs.HTTPError()

    def get_project_infos(self, project_id):
        """Get detailed project infos via WebSocket (replaces broken socketIO_client approach).

        Overleaf's Socket.IO endpoint is accessed by:
        1. GET /socket.io/1/?projectId=<id>  -> returns "<socket_id>:..."
        2. WSS /socket.io/1/websocket/<socket_id>?projectId=<id>&esh=1&ssp=1
           - recv() the connection acknowledgement
           - send("joinProjectResponse") to trigger the server response
           - recv() the JSON payload containing project data
        """
        import time
        project_page_url = PROJECT_PAGE_URL.format(project_id)

        # Step 1: obtain the Socket.IO session id.
        # Use a session so response cookies (e.g. load-balancer routing) are captured.
        s = reqs.Session()
        s.headers.update({"User-Agent": BROWSER_UA})
        resp = s.get(
            SOCKET_ID_URL.format(project_id) + f"&t={int(time.time() * 1000)}",
            headers={"Cookie": self._cookie_str, "Referer": project_page_url},
        )
        resp.raise_for_status()
        socket_str = resp.text.split(":")[0]

        # Build cookie string: original session cookie + any routing cookies the
        # handshake response set (e.g. GCLB for sticky load-balancer routing).
        ws_cookie = self._cookie_str
        extra = "; ".join(f"{k}={v}" for k, v in s.cookies.items()
                          if k not in self._cookie_str)
        if extra:
            ws_cookie += "; " + extra

        # Step 2: WebSocket upgrade.
        # The server auto-emits joinProjectResponse because projectId is in the
        # query string — we must NOT send it ourselves, only recv it.
        ws = websocket.WebSocket()
        ws.connect(
            SOCKET_URL.format(socket_str, project_id),
            header={"User-Agent": BROWSER_UA},
            cookie=ws_cookie,
            origin="https://www.overleaf.com",
            host="www.overleaf.com",
        )
        ws.recv()  # Socket.IO connect frame "1::"

        # Loop: skip heartbeat / other frames until joinProjectResponse arrives
        response = ""
        for _ in range(20):
            response = ws.recv()
            if '"joinProjectResponse"' in response:
                break
        ws.close()

        idx = response.find("{")
        project_info = json.loads(response[idx:])['args'][0]['project']
        return project_info

    def _get_csrf_token(self, project_id):
        """Fetch a fresh CSRF token from the project page (required before uploads)."""
        resp = reqs.get(PROJECT_PAGE_URL.format(project_id), headers=self._h())
        if resp.ok:
            soup = BeautifulSoup(resp.content, 'html.parser')
            meta = soup.find('meta', {'name': 'ol-csrfToken'})
            if meta:
                self._csrf = meta.get('content')
        return self._csrf

    def upload_file(self, project_id, project_infos, file_name, file_size, file):
        # Always refresh CSRF from the project page — the stored token may be stale.
        csrf = self._get_csrf_token(project_id)

        folder_id = project_infos['rootFolder'][0]['_id']
        if PATH_SEP in file_name:
            local_folders = file_name.split(PATH_SEP)[:-1]
            current_overleaf_folder = project_infos['rootFolder'][0]['folders']
            for local_folder in local_folders:
                exists_on_remote = False
                for remote_folder in current_overleaf_folder:
                    if local_folder.lower() == remote_folder['name'].lower():
                        exists_on_remote = True
                        folder_id = remote_folder['_id']
                        current_overleaf_folder = remote_folder['folders']
                        break
                if not exists_on_remote:
                    new_folder = self.create_folder(project_id, folder_id, local_folder)
                    current_overleaf_folder.append(new_folder)
                    folder_id = new_folder['_id']
                    current_overleaf_folder = new_folder['folders']

        # Use just the base filename — the folder is addressed via folder_id.
        base_name = file_name.split(PATH_SEP)[-1]

        def _do_upload():
            file.seek(0)
            # Overleaf's current upload API (2024+):
            #   folder_id goes in the query string, not the form body.
            #   Form fields: relativePath="null", name=<basename>, type=<mime>.
            #   The Fine Uploader qqfilename/qquuid fields are no longer used.
            return reqs.post(
                UPLOAD_URL.format(project_id),
                headers=self._h({
                    "x-csrf-token": csrf,
                    "Referer": PROJECT_PAGE_URL.format(project_id),
                    "Accept": "application/json",
                    "Cache-Control": "no-cache",
                }),
                params={"folder_id": folder_id},
                data={
                    "relativePath": "null",
                    "name": base_name,
                    "type": "application/octet-stream",
                },
                files={"qqfile": (base_name, file, "application/octet-stream")},
            )

        r = _do_upload()

        if r.status_code == 422:
            # File already exists — delete it first, then re-upload.
            self.delete_file(project_id, project_infos, file_name)
            r = _do_upload()

        if not r.ok:
            raise Exception(f"Upload failed HTTP {r.status_code}: {r.text[:300]}")
        result = json.loads(r.content)
        if not result.get("success"):
            raise Exception(f"Upload rejected by Overleaf: {r.text[:300]}")
        return True

    def _find_entity(self, project_infos, file_name):
        """Find a doc or fileRef by name, searching recursively through folders."""
        base = file_name.split(PATH_SEP)[-1]
        parts = file_name.split(PATH_SEP)[:-1]
        folder = project_infos['rootFolder'][0]
        for part in parts:
            folder = next((f for f in folder.get('folders', [])
                           if f['name'].lower() == part.lower()), None)
            if folder is None:
                return None
        return (next((v for v in folder.get('docs', []) if v['name'] == base), None)
                or next((v for v in folder.get('fileRefs', []) if v['name'] == base), None))

    def delete_file(self, project_id, project_infos, file_name):
        entity = self._find_entity(project_infos, file_name)
        if entity is None:
            return False
        r = reqs.delete(
            DELETE_URL.format(project_id, entity['_id']),
            headers=self._h({"X-Csrf-Token": self._csrf}),
            json={},
        )
        return r.status_code == 204

    def download_pdf(self, project_id):
        extra = {"X-Csrf-Token": self._csrf}
        body = {
            "check": "silent",
            "draft": False,
            "incrementalCompilesEnabled": True,
            "rootDoc_id": "",
            "stopOnFirstError": False,
        }
        r = reqs.post(COMPILE_URL.format(project_id), headers=self._h(extra), json=body)
        if not r.ok:
            raise reqs.HTTPError()
        compile_result = json.loads(r.content)
        if compile_result["status"] != "success":
            raise reqs.HTTPError()
        pdf_file = next(v for v in compile_result['outputFiles'] if v['type'] == 'pdf')
        download_req = reqs.get(BASE_URL + pdf_file['url'], headers=self._h(extra))
        if download_req.ok:
            return pdf_file['path'], download_req.content
        return None
PYEOF

          # Call prompt_credentials() before execute_action() so the prompts
          # appear before yaspin takes over the terminal.
          substituteInPlace olsync/olsync.py \
            --replace-fail \
              'click.clear()
    execute_action(lambda: login_handler(cookie_path), "Login",' \
              'click.clear()
    olbrowserlogin.prompt_credentials()
    execute_action(lambda: login_handler(cookie_path), "Login",'
        '';

        doCheck = false;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [ overleaf-sync ];
      };
    };
}
