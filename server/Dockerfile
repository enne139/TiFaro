# Il server di TiFaro in un container: si compila in un'immagine con Go e si
# copia il solo programma in un'immagine minima, senza shell né pacchetti.

# La compilazione gira sempre sulla macchina che costruisce (BUILDPLATFORM) e
# produce il programma per quella di destinazione: Go compila per ARM senza
# emulazione, quindi l'immagine per arm64 costa quanto quella per amd64.
FROM --platform=$BUILDPLATFORM docker.io/library/golang:1.27-alpine AS compilazione
WORKDIR /sorgente
COPY go.mod go.sum ./
RUN go mod download
COPY *.go ./
ARG TARGETOS
ARG TARGETARCH
ARG VERSIONE=sviluppo
# CGO_ENABLED=0: SQLite è in Go puro, il programma non ha bisogno di niente.
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -trimpath -ldflags "-s -w -X main.versione=${VERSIONE}" -o /tifaro-server .

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=compilazione /tifaro-server /tifaro-server
ENV TIFARO_DATI=/data TIFARO_BACKUP=/backup TIFARO_INDIRIZZO=:8645
EXPOSE 8645
VOLUME ["/data", "/backup"]
# L'immagine non ha curl: il controllo lo fa il programma stesso.
HEALTHCHECK --interval=1m --timeout=5s --start-period=10s CMD ["/tifaro-server", "salute"]
ENTRYPOINT ["/tifaro-server"]
