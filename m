Content-Type: multipart/mixed; boundary="===============0255398080185710925=="
MIME-Version: 1.0
From: Ossama Othman <ossama.othman@intel.com>
Subject: [PATCH] gpio: fix clang -Wpointer-bool-conversion warning
Date: Wed, 19 Jun 2019 13:31:50 -0700
Message-ID: <20190619203150.8334-1-ossama.othman@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0255398080185710925==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Remove a check that incorrectly attempted to determine if the "name"
field of a struct gpioline_info object was NULL.  It relied on a
pointer-to-bool conversion that didn't work as expected since the
"name" field is an array, not a pointer.  The address of an array
always evaluates to true when converted to a boolean.  In this case,
there is no need for a NULL pointer check.
---
 ell/gpio.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/ell/gpio.c b/ell/gpio.c
index bd0e9c9..c470ba9 100644
--- a/ell/gpio.c
+++ b/ell/gpio.c
@@ -189,9 +189,6 @@ LIB_EXPORT bool l_gpio_chip_find_line_offset(struct l_g=
pio_chip *chip,
 		if (ioctl(chip->fd, GPIO_GET_LINEINFO_IOCTL, &info) < 0)
 			return false;
 =

-		if (!info.name)
-			continue;
-
 		if (strcmp(info.name, line_label) !=3D 0)
 			continue;
 =

-- =

2.20.1


--===============0255398080185710925==--

