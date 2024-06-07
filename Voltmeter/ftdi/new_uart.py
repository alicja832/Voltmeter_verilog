import pyftdi.serialext

def main():
    brate = 230400
    url = 'ftdi://ftdi:232:AB0K3Q4S/1'
    port = pyftdi.serialext.serial_for_url(url, baudrate=brate, bytesize=8, stopbits=1, parity='N', xonxoff=False, rtscts=False)

    try:
        # Send bytes
        print("Transmition at", brate)
        b = bytes([0x33, 0xC7])
        print("-", b)
        port.write(b)
        print("Receiving at", brate)
        buffer = bytearray()

        while True:
            data = port.read(1) # Read one byte at a time
            if data:
                buffer.extend(data)
            if len(buffer) >= 7:
                print("Received 7 bytes:", buffer[:7])
                buffer = buffer[7:] # Clear the buffer
    
    except Exception as e:
        print("An error occurred:", e)
    finally:
        port.close()

if __name__ == "__main__":
    main()