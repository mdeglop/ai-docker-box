import io
import json
import subprocess
import sys
from contextlib import redirect_stdout, redirect_stderr
from flask import Flask, request, jsonify

app = Flask(__name__)


@app.route("/run-python", methods=["POST"])
def run_python():
    """
    Body: {"code": "<python code>"}
    Executes Python code inside this container and returns stdout/stderr.
    """
    data = request.get_json(force=True, silent=True) or {}
    code = data.get("code", "")

    if not code.strip():
        return jsonify({"error": "No code provided"}), 400

    stdout_buf = io.StringIO()
    stderr_buf = io.StringIO()

    local_vars = {}

    try:
        with redirect_stdout(stdout_buf), redirect_stderr(stderr_buf):
            exec(code, {}, local_vars)
        success = True
    except Exception as e:
        success = False
        print(f"Exception: {e}", file=stderr_buf)

    return jsonify({
        "success": success,
        "stdout": stdout_buf.getvalue(),
        "stderr": stderr_buf.getvalue(),
    })


@app.route("/run-bash", methods=["POST"])
def run_bash():
    """
    Body: {"cmd": "ls -la"}
    Runs a bash command and returns stdout/stderr/exit_code.
    """
    data = request.get_json(force=True, silent=True) or {}
    cmd = data.get("cmd", "")

    if not cmd.strip():
        return jsonify({"error": "No cmd provided"}), 400

    proc = subprocess.Popen(
        cmd,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )
    out, err = proc.communicate()

    return jsonify({
        "success": proc.returncode == 0,
        "exit_code": proc.returncode,
        "stdout": out,
        "stderr": err,
    })


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"})


if __name__ == "__main__":
    # Bind to all interfaces so host can access on localhost:8000
    app.run(host="0.0.0.0", port=8000)
