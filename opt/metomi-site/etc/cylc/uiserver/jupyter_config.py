# Insecure workaround for browser permissions error
# See https://stackoverflow.com/questions/70753768/jupyter-notebook-access-to-the-file-was-denied
c.ServerApp.use_redirect_file = False

if 'path' in locals():
    # Cylc Hub ONLY

    from pathlib import Path
    import re
    import sys

    c.JupyterHub.bind_url = 'http://:80'

    c.JupyterHub.template_paths = [path.parent / 'customised-interface']

    from cylc.review.ws import get_review_service_config
    c.JupyterHub.services = [get_review_service_config()]
    c.JupyterHub.load_roles = [
        {
            "name": "user",
            "scopes": ["self", "access:services!service=cylc-review"],
        },
    ]

    # Use the dummy authenticitor
    c.JupyterHub.authenticator_class = "dummy"
    c.DummyAuthenticator.allowed_users = ["vagrant"]
    
    # Specify the location of the JupyterHub runtime files
    RUNTIME_PATH = Path('~/.cylc/uiserver').expanduser()
    c.JupyterHub.cookie_secret_file = f'{RUNTIME_PATH / "cookie_secret"}'
    c.JupyterHub.db_url = f'{RUNTIME_PATH / "jupyterhub.sqlite"}'
    c.ConfigurableHTTPProxy.pid_file = f'{RUNTIME_PATH / "jupyterhub-proxy.pid"}'
