import vibe.http.server;
import vibe.http.router;
import vibe.http.session;
import vibe.http.fileserver;
import vibe.core.core;
import vibe.core.file;
import vibe.data.json;
import vibe.inet.mimetypes;

import mysql;

import std.algorithm;
import std.array;
import std.conv : to;
import std.datetime;
import std.format : format;
import std.process;
import std.regex;
import std.stdio;
import std.string;
import std.uuid;
import std.variant;

MySQLPool client;

void getIndex(HTTPServerRequest req, HTTPServerResponse res)
{
    res.render!("index.dt");
}

void getMemstat(HTTPServerRequest req, HTTPServerResponse res)
{
    import core.memory;
    size_t usedSize = GC.stats.usedSize;
    size_t freeSize = GC.stats.freeSize;
    Json[string] obj;
    obj["usedSize"] = usedSize;
    obj["freeSize"] = freeSize;
    res.writeJsonBody(obj);
}

void main()
{
    auto host   = environment.get("ISUCON_DB_HOST", "localhost");
    auto port   = environment.get("ISUCON_DB_PORT", "3306");
    auto user   = environment.get("ISUCON_DB_USER", "root");
    auto pwd    = environment.get("ISUCON_DB_PASSWORD", "password");
    auto dbname = environment.get("ISUCON_DB_NAME", "isucon");
    auto dsn = format("host=%s;port=%s;user=%s;pwd=%s;db=%s",
                      host, port, user, pwd, dbname);
    client = new MySQLPool(dsn);

    auto router = new URLRouter;
    router.get("/", &getIndex);
    router.get("/memstat", &getMemstat);

    auto settings = new HTTPServerSettings;
    settings.port = 8080;
    settings.bindAddresses = ["::1", "127.0.0.1"];
    settings.sessionStore = new MemorySessionStore;

    listenHTTP(settings, router);

    runApplication();
}
