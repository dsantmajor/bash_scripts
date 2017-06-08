import json


def main():

    # jsonstring = '{"key1": "val1", "key2": "val2", "key3": "val3"}'

    jsonstring = '{"Name": "bridge", "Id": "d75700d21f0663b9f8985bd28f3d969829a43cfc124177594d0d50ede7c46030", "Created": "2017-06-03T10:22:52.353320622Z", "Scope": "local"}'

    jsonObj = json.loads(jsonstring)

    for key in jsonObj:
        value = jsonObj[key]
        print("The Key and value are ({}) = ({})".format(key, value))
    pass


if __name__ == '__main__':
    main()
# Testing git plus
