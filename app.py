from flask import Flask, request, jsonify, make_response
from dbhelpers import run_statement, check_endpoint_info, new_token

# import secrets
# secrets.token_hex(16)

app = Flask(__name__)

# Returns information about a single client, will error if the client_id does not exist.
@app.get('/api/client')
def get_client():
    valid_check = check_endpoint_info(request.args, ["client_id"])
    if(type(valid_check) == str):
        return valid_check
    
    id = request.args["client_id"]
    
    try:
        result = run_statement("CALL get_client(?)", [id])
        if (result):
            return make_response(jsonify(result[0]), 200)
        else:
            return make_response("Client not found", 404)
    except Exception as error:
        err = {}
        err["error"] = f"Error calling client: {error}"
        return make_response(jsonify(err), 400)

# Creates a new client that can now use the system. Also returns a valid login token meaning the user is now logged in after sign up.  Will error if there is a duplicate username or password (the user already exists)
@app.post('/api/client')
def create_client():
    valid_check = check_endpoint_info(request.json, 
                                      ["email", "first_name", "last_name", "image_url", "username", "password"])
    if(type(valid_check) == str):
        return valid_check

    email = request.json["email"]
    first_name = request.json["first_name"]
    last_name = request.json["last_name"]
    image_url = request.json["image_url"]
    username = request.json["username"]
    password = request.json["password"]

    try:
        result = run_statement("CALL create_client(?, ?, ?, ?, ?, ?)", (email, first_name, last_name, image_url, username, password))
        if (result):
            token = new_token()
            # print(token)
            result2 = run_statement("CALL set_token(?,?)", (result[0]['id'], token))
            return make_response(jsonify(result2[0]), 200)
            # return make_response(jsonify([result[0], {"token": token}]), 200)

    except Exception as error:
        err = {}
        err["error"] = f"Error creating client: {error}"
        return make_response(jsonify(err), 400)


# Modify an existing user if you have a valid token. Note that the token is sent as a header.
@app.patch('/api/client')
def update_client():
   
    valid_check = check_endpoint_info(request.headers, ["token"])
    if(type(valid_check) == str):
        return valid_check

    email = request.json["email"]
    first_name = request.json["first_name"]
    last_name = request.json["last_name"]
    image_url = request.json["image_url"]
    username = request.json["username"]
    password = request.json["password"]

    token = request.headers["token"]

    try:
        result = run_statement("CALL update_client(?, ?, ?, ?, ?, ?, ?)", (email, first_name, last_name, image_url, username, password, token))
        if (result):
            
            return make_response(None, 200)
    except Exception as error:
        err = {}
        err["error"] = f"Error updating client: {error}"
        return make_response(jsonify(err), 400)


# Delete an existing user if you have a valid token and password. Note that the token is sent as a header.
@app.delete('/api/client')
def delete_client():
    valid_check = check_endpoint_info(request.headers,  ["token"])
    if(type(valid_check) == str):
        return valid_check
    
    password = request.json["password"]
    token = request.headers["token"]
    try:
        result = run_statement("CALL delete_client(?, ?)", (password, token))
        if (result):
            
            return make_response(None, 200)
    except Exception as error:
        err = {}
        err["error"] = f"Error deleting client: {error}"
        return make_response(jsonify(err), 400)


# Log a client in. Will error if the email / password don't exist in the system.
@app.post('/api/client-login')
def client_login():
    valid_check = check_endpoint_info(request.json, ["username", "password"])
    if(type(valid_check) == str):
        return valid_check

    username = request.json["username"]
    password = request.json["password"]

    try:
        result = run_statement("CALL client_login(?, ?)", (username, password))
        if (result):
            token = new_token()
            result2 = run_statement("CALL set_token(?,?)", (result[0]['id'], token))
            return make_response(jsonify(result2[0]), 200)
    except Exception as error:
        err = {}
        err["error"] = f"Error logging in client: {error}"
        return make_response(jsonify(err), 400)

# Delete an existing token. Will error if the token sent does not exist.
@app.delete('/api/client-login')
def client_logout():
    valid_check = check_endpoint_info(request.headers,  ["token"])
    if(type(valid_check) == str):
        return valid_check
    
    token = request.headers["token"]
    try:
        result = run_statement("CALL client_logout(?)", (token))
        if (result):
            return make_response(None, 200)
    except Exception as error:
        err = {}
        err["error"] = f"Error logging out client: {error}"
        return make_response(jsonify(err), 400)

# restaurant
# Returns information about a single restaurant, will error if the restaurant_id does not exist.
@app.get('/api/restaurant')
def get_restaurant():
    valid_check = check_endpoint_info(request.json, ["restaurant_id"])
    if(type(valid_check) == str):
        return valid_check
    
    id = request.json["restaurant_id"]
    
    try:
        result = run_statement("CALL get_restaurant(?)", (id))
        if (result):
            return make_response(jsonify(result[0]), 200)
    except Exception as error:
        err = {}
        err["error"] = f"Error calling client: {error}"
        return make_response(jsonify(err), 400)
    
# Creates a new restaurant that can now use the system. Also returns a valid login token meaning the restaurant is now logged in after sign up. Will error if there is a duplicate email or phone number(the user already exists)
@app.post('/api/restaurant')
def create_restaurant():
    # name, address, phone, email, bio, city, profile_url, banner_url, password
    valid_check = check_endpoint_info(request.json, ["name", "address", "phone", "email", "bio", "city", "profile_url", "banner_url", "password"])
    if(type(valid_check) == str):
        return valid_check

    name = request.json["name"]
    address = request.json["address"]
    phone = request.json["phone"]
    email = request.json["email"]
    bio = request.json["bio"]
    city = request.json["city"]
    profile_url = request.json["profile_url"]
    banner_url = request.json["banner_url"]
    password = request.json["password"]

    try:
        result = run_statement("CALL create_restaurant(?,?,?,?,?,?,?,?,?)", (name, address, phone, email, bio, city, profile_url, banner_url, password))
        if (result):
            token = new_token()
            result2 = run_statement("CALL set_token_restaurant(?,?)", (result[0]['id'], token))
            return make_response(jsonify(result2[0]), 200)
            # return make_response(jsonify([result[0], {"token": token}]), 200)

    except Exception as error:
        err = {}
        err["error"] = f"Error creating restaurant: {error}"
        return make_response(jsonify(err), 400)

# Modify an existing restaurant if you have a valid token. Note that the token is sent as a header.
@app.patch('/api/restaurant')
def update_restaurant():
    valid_check = check_endpoint_info(request.headers.get("token"))
    if(type(valid_check) == str):
        return valid_check
    name = request.json["name"]
    address = request.json["address"]
    phone = request.json["phone"]
    email = request.json["email"]
    bio = request.json["bio"]
    city = request.json["city"]
    profile_url = request.json["profile_url"]
    banner_url = request.json["banner_url"]
    password = request.json["password"]

    token = request.headers["token"]

    try:
        result = run_statement("CALL update_restaurant(?,?,?,?,?,?,?,?,?,?)", (name, address, phone, email, bio, city, profile_url, banner_url, password, token))
        if (result):
            
            return make_response(None, 200)
    except Exception as error:
        err = {}
        err["error"] = f"Error updating client: {error}"
        return make_response(jsonify(err), 400)


# Delete an existing restaurant if you have a valid token and password. Note that the token is sent as a header.
@app.delete('/api/restaurant')
def delete_restaurant():
    valid_check = check_endpoint_info(request.headers,  ["token"])
    if(type(valid_check) == str):
        return valid_check
    
    password = request.json["password"]
    token = request.headers["token"]
    try:
        result = run_statement("CALL delete_restaurant(?, ?)", (password, token))
        if (result):
            
            return make_response(None, 200)
    except Exception as error:
        err = {}
        err["error"] = f"Error deleting restaurant: {error}"
        return make_response(jsonify(err), 400)

# Returns information about all restaurants.
@app.get('/api/restaurants')
def get_restaurants():
    try:
        result = run_statement("CALL get_restaurants()")
        if (result):
            return make_response(jsonify(result), 200)
    except Exception as error:
        err = {}
        err["error"] = f"Error getting all restaurants: {error}"
        return make_response(jsonify(err), 400)
    
# Log a restaurant in. Will error if the email / password don't exist in the system.
@app.post('/api/restaurant-login')
def restaurant_login():
    valid_check = check_endpoint_info(request.json, ["email", "password"])
    if(type(valid_check) == str):
        return valid_check

    username = request.json["email"]
    password = request.json["password"]

    try:
        result = run_statement("CALL restaurant_login(?, ?)", (username, password))
        if (result):
            token = new_token()
            result2 = run_statement("CALL set_token_restaurant(?,?)", (result[0]['id'], token))
            return make_response(jsonify(result2[0]), 200)
    except Exception as error:
        err = {}
        err["error"] = f"Error logging in restaurant: {error}"
        return make_response(jsonify(err), 400)

# Delete an existing token. Will error if the token sent does not exist.
@app.delete('/api/restaurant-login')
def restaurant_logout():
    valid_check = check_endpoint_info(request.headers,  ["token"])
    if(type(valid_check) == str):
        return valid_check
    
    token = request.headers["token"]
    try:
        result = run_statement("CALL restaurant_logout(?)", (token))
        if (result):
            return make_response(None, 200)
    except Exception as error:
        err = {}
        err["error"] = f"Error logging out restaurant: {error}"
        return make_response(jsonify(err), 400)

# Returns all menu items associated with a restaurant.
@app.get('/api/menu')
def get_menu_item():
    valid_check = check_endpoint_info(request.args,  ["restaurant_id"])
    if(type(valid_check) == str):
        return valid_check
    
    id = request.args["restaurant_id"]

    try:
        result = run_statement("CALL get_menu_item(?)", (id))
        if (result):
            return make_response(jsonify(result), 200)
    except Exception as error:
        err = {}
        err["error"] = f"Error getting menu item: {error}"
        return make_response(jsonify(err), 400)

# Add a new menu item to a restaurant. Must be logged in as the restaurant to send the correct token.  
# Note that the token is sent as a header.
@app.post('/api/menu')
def new_menu_item():
    # description, image_url, name, price, restaurant_id
    valid_check = check_endpoint_info(request.json, 
                                      ["description", "image_url", "name", "price", "restaurant_id"])
    if(type(valid_check) == str):
        return valid_check
    
    valid_check = check_endpoint_info(request.headers, 
                                      ["token"])
    if(type(valid_check) == str):
        return valid_check

    description = request.json["description"]
    image_url = request.json["image_url"]
    name = request.json["name"]
    price = request.json["price"]
    restaurant_id = request.json["restaurant_id"]

    token = request.headers["token"]

    try:
        run_statement("CALL new_menu_item(?,?,?,?,?,?)", (description, image_url, name, price, restaurant_id, token))
        return make_response(None, 200)
    except Exception as error:
        err = {}
        err["error"] = f"Error creating menu item: {error}"
        return make_response(jsonify(err), 400)


# Modify an existing menu item if you have a valid token and menu_id. Note that the token is sent as a header.
@app.patch('/api/menu')
def edit_menu_item():
    valid_check = check_endpoint_info(request.json, 
                                      ["description", "image_url", "name", "price", "restaurant_id", "menu_id"])
    if(type(valid_check) == str):
        return valid_check
    
    valid_check = check_endpoint_info(request.headers, 
                                      ["token"])
    if(type(valid_check) == str):
        return valid_check

    description = request.json["description"]
    image_url = request.json["image_url"]
    name = request.json["name"]
    price = request.json["price"]
    restaurant_id = request.json["restaurant_id"]
    menu_id = request.json["menu_id"]

    token = request.headers["token"]

    try:
        run_statement("CALL edit_menu_item(?,?,?,?,?,?,?)", (description, image_url, name, price, restaurant_id, token, menu_id))
        return make_response(None, 200)
    except Exception as error:
        err = {}
        err["error"] = f"Error editing menu item: {error}"
        return make_response(jsonify(err), 400)

# Delete an existing menu item if you have a valid token. Note that the token is sent as a header.
@app.delete('/api/menu')
def delete_menu_item():
    valid_check = check_endpoint_info(request.json, 
                                      ["menu_id"])
    if(type(valid_check) == str):
        return valid_check
    
    valid_check = check_endpoint_info(request.headers, 
                                      ["token"])
    if(type(valid_check) == str):
        return valid_check

    id = request.json["menu_id"]
    token = request.headers["token"]

    try:
        run_statement("CALL delete_menu_item(?,?)", (token, id))
        return make_response(None, 200)
    except Exception as error:
        err = {}
        err["error"] = f"Error editing menu item: {error}"
        return make_response(jsonify(err), 400)
    
# Returns all orders associated with a particular client.  
# Can be customized to show all, only confirmed, or only completed orders.  
# Note that the token is sent as a header.
@app.get('/api/client-order')
def get_client_orders():
    valid_check = check_endpoint_info(request.headers, 
                                      ["token"])
    if(type(valid_check) == str):
        return valid_check

    token = request.headers["token"]

    if(request.args.get("is_confirmed") != None):
        is_confirmed = request.args.get("is_confirmed")
    else:
        is_confirmed = -1
    if(request.args.get("is_complete") != None):
        is_complete = request.args.get("is_complete")
    else:
        is_complete = -1
        
    try:
        response = run_statement("CALL get_client_order(?,?,?)", (token, is_confirmed, is_complete))
        return make_response(response, 200)
    except Exception as error:
        err = {}
        err["error"] = f"Error getting client order: {error}"
        return make_response(jsonify(err), 400)


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
def get_restaurant_orders():
    valid_check = check_endpoint_info(request.headers, 
                                      ["token"])
    if(type(valid_check) == str):
        return valid_check

    token = request.headers["token"]

    if(request.args.get("is_confirmed") != None):
        is_confirmed = request.args.get("is_confirmed")
    else:
        is_confirmed = -1
    if(request.args.get("is_complete") != None):
        is_complete = request.args.get("is_complete")
    else:
        is_complete = -1
    try:
        response = run_statement("CALL get_restaurant_order(?,?,?)", (token, is_confirmed, is_complete))
        return make_response(response, 200)
    except Exception as error:
        err = {}
        err["error"] = f"Error getting restaurant order: {error}"
        return make_response(jsonify(err), 400)

# Modify an existing order.  
# Orders can be confirmed and then completed only by the restaurant associated with the order.  
# Note if you try to complete and order that has not been confirmed, it will automatically be confirmed as well.  
# Note that the token is sent as a header.
@app.patch('/api/restaurant-order')
def edit_restaurant_order():
    return

app.run(debug=True)