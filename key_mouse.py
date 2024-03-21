import os
from dotenv import load_dotenv
from websocket import create_connection
import json
import math
import pyautogui
import numpy as np
import vgamepad as vg

gamepad = vg.VX360Gamepad()

load_dotenv()

clientId = os.getenv("clientId")
clientSecret = os.getenv("clientSecret")

def send_message(j):
    j = json.dumps(j)
    ws.send(j)
    response = ws.recv()
    return (response)



ws = create_connection("wss://localhost:6868")


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
print("cortexToken ", cortexToken)


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
print(createSession)
sessionId = createSession['result']['id']
print(sessionId)

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
        "streams": ["mot", "com", "fac"]
    }
})

ws.recv()
subscribe = json.loads(subscribe)
print(subscribe)

print( "Sent")
print( "Receiving...")

def give_roll_pitch(quat):
    # Normalize the quaternion
    quat_mag = math.sqrt(sum(x * x for x in quat))
    quat = [x / quat_mag for x in quat]

    # Convert quaternion to Euler angles
    roll = math.atan2(2*(quat[0]*quat[1] + quat[2]*quat[3]), 1 - 2*(quat[1]**2 + quat[2]**2))
    pitch = math.asin(2*(quat[0]*quat[2] - quat[3]*quat[1]))
    yaw = math.atan2(2*(quat[0]*quat[3] + quat[1]*quat[2]), 1 - 2*(quat[2]**2 + quat[3]**2))

    # Extract roll and pitch angles
    roll_degrees = math.degrees(roll)
    pitch_degrees = math.degrees(pitch)

    # Map roll and pitch angles to joystick range (-1, 1)
    mapped_roll = roll_degrees / 90  # Assuming maximum roll angle of 90 degrees
    mapped_pitch = pitch_degrees / 90  # Assuming maximum pitch angle of 90 degrees

    return mapped_roll, mapped_pitch


def convert_coordinates(x_old, y_old):
    new_x = int((x_old + 1.0) * 1919 / 2)
    new_y = int((y_old + 1.0) * 1079 / 2)
    return new_x, new_y

result = ws.recv()
result = json.loads(result)

init_mapped_roll, init_mapped_pitch = give_roll_pitch(result["mot"][8:12])
x_center, y_center = init_mapped_roll, init_mapped_pitch

while True:
    result = ws.recv()
    # print("Received ", result)
    result = json.loads(result)
    
    if "com" in result:
        action = result["com"][0]
        power = result["com"][1]

        if action == "push" and power >= 0.5:
            pyautogui.keyDown('w')
            print("Received ", result)
        # if action == "lift" and power >= 0.5:
        #     gamepad.release_button(button=vg.XUSB_BUTTON.XUSB_GAMEPAD_DPAD_UP)
        #     print("Received ", result)
        else:
            pyautogui.keyUp('w')
        

    # elif "mot" in result:
    #     quat = [result["mot"][8], result["mot"][9], result["mot"][10], result["mot"][11]]
    #     mapped_roll, mapped_pitch = give_roll_pitch(quat)

    #     gamepad.right_joystick_float(x_value_float= mapped_roll - init_mapped_roll , y_value_float = mapped_pitch - init_mapped_pitch)
    #     gamepad.update()

    elif "fac" in result:
        action = result["fac"][3]
        power = result["fac"][4]

        if action == "smile" and power >= 0.8:
            gamepad.press_button(button=vg.XUSB_BUTTON.XUSB_GAMEPAD_A)
            print("Received ", result)
        else:
            gamepad.release_button(button=vg.XUSB_BUTTON.XUSB_GAMEPAD_A)

        gamepad.update()


    

ws.close