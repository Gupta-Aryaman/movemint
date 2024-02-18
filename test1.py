import asyncio
import websockets

async def receive_messages(ws):
    while True:
        result = await ws.recv()
        print("Received: %s" % result)

async def send_messages(ws):
    while True:
        message = input("Enter message to send (or 'exit' to quit): ")
        if message.lower() == 'exit':
            break
        await ws.send(message)

async def main():
    uri = "wss://localhost:6868"
    async with websockets.connect(uri) as ws:
        receive_task = asyncio.create_task(receive_messages(ws))
        send_task = asyncio.create_task(send_messages(ws))

        # Wait for both tasks to complete
        await asyncio.gather(receive_task, send_task)

if __name__ == "__main__":
    asyncio.run(main())
