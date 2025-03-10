from flask import Flask, request, send_file
import logging
from datetime import datetime

app = Flask(__name__)

logging.basicConfig(level=logging.INFO)

@app.route('/usage/<email_id>.png') 
def track_email(email_id):
    log_message = f"Email opened by {email_id} - {request.remote_addr} - {datetime.now()}"
    app.logger.info(log_message)
    
    return send_file("pixel.png", mimetype="image/png")
    # to embed: <img src="https://<domain>/usage/<email_id>.png" width="1" height="1" style="display:none;" />
    
if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)