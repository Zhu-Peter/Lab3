from flask import Flask, request, jsonify, make_response
from dbhelpers import run_statement, check_endpoint_info

# import secrets
# secrets.token_hex(16)

app = Flask(__name__)

# Returns information about a single client, will error if the client_id does not exist.
@app.get('/api/client')
def get_client():
    valid_check = check_endpoint_info(request.json, ["client_id"])
    if(type(valid_check) == str):
        return valid_check
    
    id = request.args["client_id"]
    
    try:
        result = run_statement("CALL get_client(?)", (id))
        if (result):
            return make_response(jsonify(result[0]), 200)
    except Exception as error:
        err = {}
        err["error"] = f"Error calling client: {error}"
        return make_response(jsonify(err), 400)

# Creates a new client that can now use the system. Also returns a valid login token meaning the user is now logged in after sign up.  Will error if there is a duplicate username or password (the user already exists)
@app.post('/api/client')
def create_client():

    # return client_id, token
    return

# Modify an existing user if you have a valid token. Note that the token is sent as a header.
@app.patch('/api/client')
def update_client():
    
    return

# Delete an existing user if you have a valid token and password. Note that the token is sent as a header.
@app.delete('/api/client')
def delete_client():
    return

# restaurant
# Returns information about a single restaurant, will error if the restaurant_id does not exist.
@app.get('/api/restaurant')
def get_restaurant():
    valid_check = check_endpoint_info(request.json, ["restaurant_id"])
    if(type(valid_check) == str):
        return valid_check
    
    id = request.args["restaurant_id"]
    
    try:
        result = run_statement("CALL get_client(?)", (id))
        if (result):
            return make_response(jsonify(result[0]), 200)
    except Exception as error:
        err = {}
        err["error"] = f"Error calling client: {error}"
        return make_response(jsonify(err), 400)
    
# Creates a new restaurant that can now use the system. Also returns a valid login token meaning the restaurant is now logged in after sign up. Will error if there is a duplicate email or phone number(the user already exists)
@app.post('/api/restaurant')
def create_restaurant():
    return

# Modify an existing restaurant if you have a valid token. Note that the token is sent as a header.
@app.patch('/api/restaurant')
def update_restaurant():
    return

# Delete an existing restaurant if you have a valid token and password. Note that the token is sent as a header.
@app.delete('/api/restaurant')
def delete_restaurant():
    return

# Returns information about all restaurants.
@app.get('/api/restaurants')
def get_restaurants():
    try:
        result = run_statement("CALL get_restaurants()")
        if (result):
            return make_response(jsonify(result), 200)
    except Exception as error:
        err = {}
        err["error"] = f"Error calling client: {error}"
        return make_response(jsonify(err), 400)
    
# Log a restaurant in. Will error if the email / password don't exist in the system.
@app.post('/api/restaurant-login')
def restaurant_login():
    return

# Delete an existing token. Will error if the token sent does not exist.
@app.delete('/api/restaurant-login')
def restaurant_logout():
    return

# Returns all menu items associated with a restaurant.
@app.get('/api/menu')
def get_menu_item():
    return

# Add a new menu item to a restaurant. Must be logged in as the restaurant to send the correct token.  
# Note that the token is sent as a header.
@app.post('/api/menu')
def new_menu_item():
    return

# Modify an existing menu item if you have a valid token and menu_id. Note that the token is sent as a header.
@app.patch('/api/menu')
def edit_menu_item():
    return

# Delete an existing menu item if you have a valid token. Note that the token is sent as a header.
@app.delete('/api/menu')
def delete_menu_item():
    return

# Returns all orders associated with a particular client.  
# Can be customized to show all, only confirmed, or only completed orders.  
# Note that the token is sent as a header.
@app.get('/api/client-order')
def get_client_order():
    return

# Create a new order for a restaurant to see.  
# Note that one order must be associated with one restaurant only.  
# Note that the token is sent as a header.
@app.post('/api/client-order')
def new_client_order():
    return

# Returns all orders associated with a particular restaurant.  
# Can be customized to show all, only confirmed, or only completed orders.  
# Send no params if you want all orders associated with a restaurant regardless of status.
# Note that the token is sent as a header.
@app.get('/api/restaurant-order')
def get_restaurant_order():
    return

# Modify an existing order.  
# Orders can be confirmed and then completed only by the restaurant associated with the order.  
# Note if you try to complete and order that has not been confirmed, it will automatically be confirmed as well.  
# Note that the token is sent as a header.
@app.patch('/api/restaurant-order')
def edit_restaurant_order():
    return