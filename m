Content-Type: multipart/mixed; boundary="===============2555923253832766899=="
MIME-Version: 1.0
From: Phil <philip.hodges@bluewin.ch>
Subject: ctype.h undefined behaviour on signed char platforms, needs cast to
 (unsigned char)
Date: Sat, 21 Nov 2020 10:52:20 +0100
Message-ID: <75C926A4-7EC8-4392-BB83-69A143D2FD4F@bluewin.ch>
In-Reply-To: <814B09B7-CAAB-487B-9F42-8C0A2169A015@bluewin.ch>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============2555923253832766899==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Just a little reminder that a cast to (unsigned char) is needed when passin=
g a possibly negative char to ctype functions like isalnum, isspace. Passin=
g anything other than positive or -1 is undefined behaviour, on platforms w=
here char is signed.

One way to find them all is to build from time to time with ctype.h include=
 commented out. Static review tools may also help.

+#include <ctype.h>
+		while (base64_len && isspace(*base64)) {

--===============2555923253832766899==--

