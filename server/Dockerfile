# Il server di TiFaro in un container: si compila in un'immagine con Go e si
# copia il solo programma in un'immagine minima, senza shell né pacchetti.

FROM docker.io/library/golang:1.27-alpine AS compilazione
WORKDIR /sorgente
COPY go.mod go.sum ./
RUN go mod download
COPY *.go ./
ARG VERSIONE=sviluppo
# CGO_ENABLED=0: SQLite è in Go puro, il programma non ha bisogno di niente.
RUN CGO_ENABLED=0 go build -trimpath -ldflags "-s -w -X main.versione=${VERSIONE}" -o /tifaro-server .

FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=compilazione /tifaro-server /tifaro-server
ENV TIFARO_DATI=/data TIFARO_BACKUP=/backup TIFARO_INDIRIZZO=:8645
EXPOSE 8645
VOLUME ["/data", "/backup"]
# L'immagine non ha curl: il controllo lo fa il programma stesso.
HEALTHCHECK --interval=1m --timeout=5s --start-period=10s CMD ["/tifaro-server", "salute"]
ENTRYPOINT ["/tifaro-server"]
