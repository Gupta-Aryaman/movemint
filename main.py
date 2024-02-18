import os
from dotenv import load_dotenv
from websocket import create_connection
import json
import vgamepad as vg
import math

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


subscribe = send_message({
    "id": 1,
    "jsonrpc": "2.0",
    "method": "subscribe",
    "params": {
        "cortexToken": cortexToken,
        "session": sessionId,
        "streams": ["mot"]
    }
})

subscribe = json.loads(subscribe)
print(subscribe)

print( "Sent")
print( "Receiving...")

result = ws.recv()
result = json.loads(result)
prev_left_x = result["mot"][2]
prev_left_y = result["mot"][3]
prev_right_x = result["mot"][5]
prev_right_y = result["mot"][6]

print(
    "Left X: ", prev_left_x, 
    "Left Y: ", prev_left_y, 
    "Right X: ", prev_right_x, 
    "Right Y: ", prev_right_y
)

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

result = ws.recv()
result = json.loads(result)

init_mapped_roll, init_mapped_pitch = give_roll_pitch(result["mot"][8:12])

while True:
    result = ws.recv()
    print("Received ", result)
    result = json.loads(result)
    
    left_x = result["mot"][8]
    left_y = result["mot"][9]
    right_x = result["mot"][10]
    right_y = result["mot"][11]

    quat = [left_x, left_y, right_x, right_y]
    # gamepad.left_joystick_float(x_value_float= left_x - prev_left_x , y_value_float = left_y - prev_left_y)

    mapped_roll, mapped_pitch = give_roll_pitch(quat)

    # gamepad.right_joystick_float(x_value_float=right_x - prev_right_x, y_value_float=right_y - prev_right_y)
    gamepad.right_joystick_float(x_value_float= mapped_roll - init_mapped_roll , y_value_float = mapped_pitch - init_mapped_pitch)
    # print(
    #     "x = ", prev_right_x - right_x,
    #     "y = ", prev_right_y - right_y
    # )
    # prev_left_x = left_x
    # prev_left_y = left_y
    # prev_right_x = right_x
    # prev_right_y = right_y

    # gamepad.left_joystick_float(x_value_float=right_x, y_value_float=right_y)
    # gamepad.right_joystick_float(x_value_float=left_x, y_value_float=lef`t_y)
    gamepad.update()
ws.close