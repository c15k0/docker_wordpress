vcl 4.0;

# -- Define your backend (Nginx) --

backend default {
    .host = "nginx";
    .port = "80";
}

# -- ACL for PURGE requests (adjust IPs as needed) --

acl purge {
    "localhost";
    "172.0.0.0"/8;    # Docker internal network
}

sub vcl_recv {
    if (req.method == "PURGE") {
        if (client.ip ~ purge) {
            return (purge);
        }
        return (synth(405, "Method not allowed"));
    }

    if (req.method != "GET" && req.method != "HEAD") {
        return (pass);
    }

    if (req.url ~ "\?.*") {
        return (pass);
    }

    if (req.http.Authorization || req.http.Cookie ~ "(wordpress_|wp-postpass_|comment_author_)" ) {
        return (pass);
    }

    return (hash);
}

sub vcl_backend_response {
    if (beresp.http.Cache-Control ~ "private" || beresp.http.Cache-Control ~ "no-cache") {
        set beresp.ttl = 0s;
        return (pass);
    }

    if (bereq.url ~ "\.(png|gif|jpg|jpeg|css|js|ico|svg|woff2?)$") {
        set beresp.ttl = 30d;
    } else {
        set beresp.ttl = 5m;
    }

    set beresp.grace = 1h;
}

sub vcl_deliver {
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
    } else {
        set resp.http.X-Cache = "MISS";
    }
}
