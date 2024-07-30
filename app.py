from flask import Flask, request, jsonify, make_response
from dbhelpers import run_statement, check_endpoint_info


app = Flask(__name__)

@app.get('/api/client')
def get_client():
    valid_check = check_endpoint_info(request.json, ['username', 'password'])
    if(type(valid_check) == str):
        return valid_check
    
    id = request.args["client_id"]
    
    try:
        result = run_statement("CALL get_client(?)", (id))
        if (result):
            return make_response(jsonify(result), 200)
    except Exception as error:
        err = {}
        err["error"] = f"Error calling client: {error}"
        return make_response(jsonify(err), 400)

