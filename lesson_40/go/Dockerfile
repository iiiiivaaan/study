FROM golang:latest
ENV GO111MODULE=auto
WORKDIR /app
COPY myapp.go /app
RUN go build -o myapp
EXPOSE 9002
ENTRYPOINT ["./myapp"]
