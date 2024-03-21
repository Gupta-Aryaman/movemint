import os
from dotenv import load_dotenv
from websocket import create_connection
import json
from time import sleep
import firebase_admin
from firebase_admin import credentials, db

load_dotenv()

clientId = os.getenv("clientId")
clientSecret = os.getenv("clientSecret")
firebaseDatabaseUrl = os.getenv("firebaseDatabaseUrl")

# database connection
cred = credentials.Certificate("credentials.json")
firebase_admin.initialize_app(cred, {"databaseURL": firebaseDatabaseUrl})
ref = db.reference("/")

#websocket connection
ws = create_connection("wss://localhost:6868")


def send_message(j):
    j = json.dumps(j)
    ws.send(j)
    response = ws.recv()
    return (response)

getCortexToken = send_message({
        "id": 1,
        "jsonrpc": "2.0",
        "method": "authorize",
        "params": {
            "clientId": clientId,
            "clientSecret": clientSecret
        }
    })

getCortexToken = json.loads(getCortexToken)
cortexToken = getCortexToken["result"]["cortexToken"]

createSession = send_message({
    "id": 1,
    "jsonrpc": "2.0",
    "method": "createSession",
    "params": {
        "cortexToken": cortexToken,
        "headset": "EPOCX-E5020501",
        "status": "open"
    }
})

createSession = json.loads(createSession)

try:
    sessionId = createSession['result']['id']
except Exception as e:
    print(str(e))
    print("Enable to connect to headset")
    exit(1)

load_profile = send_message({
    "id": 1,
    "jsonrpc": "2.0",
    "method": "setupProfile",
    "params": {
        "cortexToken": cortexToken,
        "headset": "EPOCX-E5020501",
        "profile": "aryaman",
        "status": "load"
    }
})

subscribe = send_message({
    "id": 1,
    "jsonrpc": "2.0",
    "method": "subscribe",
    "params": {
        "cortexToken": cortexToken,
        "session": sessionId,
        "streams": ["com", "fac"]
    }
})

# available actions - 
# com stream - push, pull, lift, drop
# fac stream - smile, furrow brows, clench teeth, raise brows, wink left, wink right

ws.recv()
subscribe = json.loads(subscribe)
print(subscribe)

print( "Sent")
print( "Receiving...")


result = ws.recv()
result = json.loads(result)

flag = False

while True:
    result = ws.recv()
    result = json.loads(result)

    
    if "com" in result:
        action = result["com"][0]
        power = result["com"][1]

        if action == "push" and power >= 0.6:
            flag = True
            db.reference("/push").set({"enabled": True})
            print("Received ", result)

        elif action == "pull" and power >= 0.6:
            flag = True
            db.reference("/pull").set({"enabled": True})
            print("Received ", result)

        elif action == "lift" and power >= 0.6:
            flag = True
            db.reference("/lift").set({"enabled": True})
            print("Received ", result)

        elif action == "drop" and power >= 0.6:
            flag = True
            db.reference("/drop").set({"enabled": True})
            print("Received ", result)
        

    elif "fac" in result:
        action = result["fac"][3]
        power = result["fac"][4]

        if action == "smile" and power >= 0.8:
            flag = True
            db.reference("/smile").set({"enabled": True})
            print("Received ", result)
        elif action == "furrow brows" and power >= 0.8:
            flag = True
            db.reference("/furrow brows").set({"enabled": True})
            print("Received ", result)
        elif action == "clench teeth" and power >= 0.8:
            flag = True
            db.reference("/clench teeth").set({"enabled": True})
            print("Received ", result)
        elif action == "raise brows" and power >= 0.8:
            flag = True
            db.reference("/raise brows").set({"enabled": True})
            print("Received ", result)
        elif action == "wink left" and power >= 0.8:
            flag = True
            db.reference("/wink left").set({"enabled": True})
            print("Received ", result)
        elif action == "wink right" and power >= 0.8:
            flag = True
            db.reference("/wink right").set({"enabled": True})
            print("Received ", result)

        # print("Received ", result)
            
    if flag == True:
        sleep(10)
        flag = False


ws.close