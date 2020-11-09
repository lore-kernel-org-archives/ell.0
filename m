Content-Type: multipart/mixed; boundary="===============4343785594703566511=="
MIME-Version: 1.0
From: Nuno =?unknown-8bit?q?Gon=C3=A7alves?= <nunojpg@gmail.com>
Subject: [PATCH] Check for NULL on output function pointer
Date: Mon, 09 Nov 2020 10:05:40 +0000
Message-ID: <CAEXMXLRbHRt95-=yGeUx=v7Weo3wcHVEkd4fQW4t1NJtmkXYXg@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4343785594703566511==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

While l_util_hexdump, l_util_hexdump_two and l_util_debug check
for a eventual NULL function pointer, l_util_hexdumpv did not.

Add the same check to l_util_hexdumpv to make the interface uniform.

Signed-off-by: Nuno Goncalves <nunojpg@gmail.com>
---
 ell/util.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/ell/util.c b/ell/util.c
index 1db063b..6088e3c 100644
--- a/ell/util.c
+++ b/ell/util.c
@@ -527,6 +527,9 @@ LIB_EXPORT void l_util_hexdumpv(bool in, const
struct iovec *iov,
        size_t c;
        const uint8_t *buf;

+       if (likely(!function))
+               return;
+
        if (unlikely(!iov || !n_iov))
                return;

-- =

2.25.1
--===============4343785594703566511==--

