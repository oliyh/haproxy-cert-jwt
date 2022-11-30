# haproxy-cert-jwt

A Lua extension to HAProxy supporting encoding of a client SSL certificate into a JWT in the `Authorization` header for the backend server.

Note that the JWT produced is of the JSON Web Signature (JWS) variant. Your backend will need the secret key in order to verify the signature.

## Pre-requesites

- HAProxy compiled with Lua support
- luarocks for downloading dependencies

## Usage

Install lua dependencies:

```
git clone https://github.com/oliyh/luajwt.git
luarocks install --tree rocks luajwt/luajwt-1.0-1.rockspec
```

Then run haproxy setting the `CERT_JWT_KEY` environment variable.

```
CERT_JWT_KEY=mysecret haproxy -f haproxy.cfg
```

## Example

Build the example docker image
```
docker build . -t cert-jwt-example -f example/Dockerfile
```

Start a Docker image
```
docker run -it --rm cert-jwt-example
```

Start HAProxy with the example config:
```
CERT_JWT_KEY=some-long-and-secure-secret-key! haproxy -f haproxy.cfg &
```

And try it out:
```
curl --cert localhost.crt --key localhost.crt.key --cacert myCA.pem https://localhost/anything
```

You will see the backend request echoed back to you. Note the `Authorization` header which has been populated with the JWT.
You can use https://token.dev/ to verify the contents and signing of the JWT.

Example JWT:
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYmYiOjE2Njk4Mjg2ODEsImlzcyI6IlwvQz1BVVwvU1Q9U29tZS1TdGF0ZVwvTz1vbGl5aFwvQ049aGFwcm94eS1jZXJ0LWp3dC1leGFtcGxlIiwiaWF0IjoxNjY5ODI4NzExLCJleHAiOjE3NDExMDg2ODEsInN1YiI6ImhhcHJveHktY2VydC1qd3QtZXhhbXBsZSJ9.0osWZg5ecOAdJFvwh-IbTKr8oAienTF81MT1WwLpRIo
```

Decoded on https://token.dev/

```
{
  "nbf": 1669828681,
  "iss": "/C=AU/ST=Some-State/O=oliyh/CN=haproxy-cert-jwt-example",
  "iat": 1669828711,
  "exp": 1741108681,
  "sub": "haproxy-cert-jwt-example"
}
```
