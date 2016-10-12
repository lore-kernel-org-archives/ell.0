Content-Type: multipart/mixed; boundary="===============3580254346521573267=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: [PATCH] key: Fix Valgrind warnings
Date: Wed, 12 Oct 2016 13:51:18 -0700
Message-ID: <20161012205118.9152-1-mathew.j.martineau@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3580254346521573267==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Valgrind doesn't understand all of the keyctl syscalls and how they
set memory, so clear the encrypt/decrypt/sign output buffer to prevent
false positives.

TEST: key crypto
=3D=3D5884=3D=3D Conditional jump or move depends on uninitialised value(s)
=3D=3D5884=3D=3D    at 0x40555F: unpad (key.c:479)
=3D=3D5884=3D=3D    by 0x4057DF: l_key_decrypt (key.c:556)
=3D=3D5884=3D=3D    by 0x4021EB: test_key_crypto (test-key.c:535)
=3D=3D5884=3D=3D    by 0x4039BB: l_test_run (test.c:83)
=3D=3D5884=3D=3D    by 0x4026F3: main (test-key.c:606)
=3D=3D5884=3D=3D
=3D=3D5884=3D=3D Conditional jump or move depends on uninitialised value(s)
=3D=3D5884=3D=3D    at 0x40556F: unpad (key.c:479)
=3D=3D5884=3D=3D    by 0x4057DF: l_key_decrypt (key.c:556)
=3D=3D5884=3D=3D    by 0x4021EB: test_key_crypto (test-key.c:535)
=3D=3D5884=3D=3D    by 0x4039BB: l_test_run (test.c:83)
=3D=3D5884=3D=3D    by 0x4026F3: main (test-key.c:606)
=3D=3D5884=3D=3D
=3D=3D5884=3D=3D Conditional jump or move depends on uninitialised value(s)
=3D=3D5884=3D=3D    at 0x4055AC: unpad (key.c:483)
=3D=3D5884=3D=3D    by 0x4057DF: l_key_decrypt (key.c:556)
=3D=3D5884=3D=3D    by 0x4021EB: test_key_crypto (test-key.c:535)
=3D=3D5884=3D=3D    by 0x4039BB: l_test_run (test.c:83)
=3D=3D5884=3D=3D    by 0x4026F3: main (test-key.c:606)
=3D=3D5884=3D=3D
=3D=3D5884=3D=3D Conditional jump or move depends on uninitialised value(s)
=3D=3D5884=3D=3D    at 0x4C2FC4C: strcmp (vg_replace_strmem.c:842)
=3D=3D5884=3D=3D    by 0x40223A: test_key_crypto (test-key.c:538)
=3D=3D5884=3D=3D    by 0x4039BB: l_test_run (test.c:83)
=3D=3D5884=3D=3D    by 0x4026F3: main (test-key.c:606)
=3D=3D5884=3D=3D
=3D=3D5884=3D=3D Conditional jump or move depends on uninitialised value(s)
=3D=3D5884=3D=3D    at 0x4C2FC50: strcmp (vg_replace_strmem.c:842)
=3D=3D5884=3D=3D    by 0x40223A: test_key_crypto (test-key.c:538)
=3D=3D5884=3D=3D    by 0x4039BB: l_test_run (test.c:83)
=3D=3D5884=3D=3D    by 0x4026F3: main (test-key.c:606)
=3D=3D5884=3D=3D
=3D=3D5884=3D=3D Conditional jump or move depends on uninitialised value(s)
=3D=3D5884=3D=3D    at 0x4C2FC6C: strcmp (vg_replace_strmem.c:842)
=3D=3D5884=3D=3D    by 0x40223A: test_key_crypto (test-key.c:538)
=3D=3D5884=3D=3D    by 0x4039BB: l_test_run (test.c:83)
=3D=3D5884=3D=3D    by 0x4026F3: main (test-key.c:606)
---
 ell/key.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ell/key.c b/ell/key.c
index 0222b39..fc20d29 100644
--- a/ell/key.c
+++ b/ell/key.c
@@ -218,6 +218,8 @@ static long kernel_key_eds(int op, int32_t serial, cons=
t char *encoding,
 					     .out_len =3D len_out };
 	char *info =3D format_key_info(encoding, hash);
 =

+	memset(out, 0, len_out);
+
 	result =3D syscall(__NR_keyctl, op, &params, info ?: "", in, out);
 	l_free(info);
 =

-- =

2.10.1


--===============3580254346521573267==--

