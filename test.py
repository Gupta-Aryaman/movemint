import threading
from websocket import create_connection

def receive_messages(ws):
    while True:
        result = ws.recv()
        print("Received: %s" % result)

def send_messages(ws):
    while True:
        message = input("Enter message to send (or 'exit' to quit): ")
        if message.lower() == 'exit':
            break
        ws.send(message)
    ws.close()

if __name__ == "__main__":
    ws = create_connection("wss://localhost:6868")

    # Create two threads, one for receiving messages and one for sending messages
    receive_thread = threading.Thread(target=receive_messages, args=(ws,))
    send_thread = threading.Thread(target=send_messages, args=(ws,))

    # Start the receiving thread
    receive_thread.start()

    try:
        # Run the sending thread in the main thread
        send_messages(ws)
    except KeyboardInterrupt:
        # Catch KeyboardInterrupt (Ctrl+C) to exit the program gracefully
        pass

    # Wait for the receiving thread to finish
    receive_thread.join()

    # Close the WebSocket connection
    ws.close()
