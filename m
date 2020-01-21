Content-Type: multipart/mixed; boundary="===============8384448516471683128=="
MIME-Version: 1.0
From: =?unknown-8bit?q?Przemys=C5=82aw?= Fierek <przemyslaw.fierek@silvair.com>
Subject: [PATCH] unit: Add test-casese for l_ringbuf_append function
Date: Tue, 21 Jan 2020 09:17:49 +0100
Message-ID: <20200121081749.20090-1-przemyslaw.fierek@silvair.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============8384448516471683128==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

This patch adds unit-tests for previously submitted `l_ringbuf_append`
function.
---
 unit/test-ringbuf.c | 83 ++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 82 insertions(+), 1 deletion(-)

diff --git a/unit/test-ringbuf.c b/unit/test-ringbuf.c
index 906161b..ce2c5f9 100644
--- a/unit/test-ringbuf.c
+++ b/unit/test-ringbuf.c
@@ -131,6 +131,86 @@ static void test_printf(const void *data)
 	l_ringbuf_free(rb);
 }
 =

+static void test_append(const void *unused)
+{
+	static uint8_t data[6] =3D {1, 2, 3, 4, 5, 6};
+	static size_t rb_size =3D 12;
+	static size_t rb_capa =3D 16;
+	static size_t len_no_wrap;
+	static ssize_t appended, space_left;
+	static void *rb_data;
+	struct l_ringbuf *rb;
+
+	rb =3D l_ringbuf_new(rb_size);
+	assert(rb !=3D NULL);
+	assert(l_ringbuf_capacity(rb) =3D=3D rb_capa);
+
+	appended =3D l_ringbuf_append(rb, data, sizeof(data));
+	assert(appended =3D=3D sizeof(data));
+
+	appended =3D l_ringbuf_append(rb, data, sizeof(data));
+	assert(appended =3D=3D sizeof(data));
+
+	space_left =3D minsize(l_ringbuf_avail(rb), sizeof(data));
+	appended =3D l_ringbuf_append(rb, data, sizeof(data));
+	assert(appended =3D=3D space_left);
+
+	rb_data =3D l_ringbuf_peek(rb, 0, &len_no_wrap);
+	assert(memcmp(rb_data, data, sizeof(data)) =3D=3D 0);
+	l_ringbuf_drain(rb, sizeof(data));
+
+	rb_data =3D l_ringbuf_peek(rb, 0, &len_no_wrap);
+	assert(memcmp(rb_data, data, sizeof(data)) =3D=3D 0);
+	l_ringbuf_drain(rb, sizeof(data));
+
+	rb_data =3D l_ringbuf_peek(rb, 0, &len_no_wrap);
+	assert(memcmp(rb_data, data, len_no_wrap) =3D=3D 0);
+	l_ringbuf_drain(rb, len_no_wrap);
+
+	l_ringbuf_free(rb);
+}
+
+static void test_append2(const void *unused)
+{
+	static uint8_t expected_data1[14] =3D {3, 4, 5, 6, 1, 2, 3, 4, 5, 6, 1, 2=
, 3, 4};
+	static uint8_t expected_data2[2] =3D {5, 6};
+	static uint8_t data[6] =3D {1, 2, 3, 4, 5, 6};
+	static size_t rb_size =3D 12;
+	static size_t rb_capa =3D 16;
+	static size_t len_no_wrap;
+	static ssize_t appended, space_left;
+	static void *rb_data;
+	struct l_ringbuf *rb;
+
+	rb =3D l_ringbuf_new(rb_size);
+	assert(rb !=3D NULL);
+	assert(l_ringbuf_capacity(rb) =3D=3D rb_capa);
+
+	appended =3D l_ringbuf_append(rb, data, sizeof(data));
+	assert(appended =3D=3D sizeof(data));
+
+	appended =3D l_ringbuf_append(rb, data, sizeof(data));
+	assert(appended =3D=3D sizeof(data));
+
+	space_left =3D minsize(l_ringbuf_avail(rb), sizeof(data));
+	l_ringbuf_drain(rb, sizeof(data) - space_left);
+
+	appended =3D l_ringbuf_append(rb, data, sizeof(data));
+	assert(appended =3D=3D sizeof(data));
+
+	rb_data =3D l_ringbuf_peek(rb, 0, &len_no_wrap);
+	assert(len_no_wrap =3D=3D sizeof(expected_data1));
+	assert(memcmp(expected_data1, rb_data, len_no_wrap) =3D=3D 0);
+
+	l_ringbuf_drain(rb, len_no_wrap);
+
+	rb_data =3D l_ringbuf_peek(rb, 0, &len_no_wrap);
+	assert(len_no_wrap =3D=3D sizeof(expected_data2));
+	assert(memcmp(expected_data2, rb_data, len_no_wrap) =3D=3D 0);
+
+	l_ringbuf_free(rb);
+}
+
 int main(int argc, char *argv[])
 {
 	l_test_init(&argc, &argv);
@@ -138,7 +218,8 @@ int main(int argc, char *argv[])
 	l_test_add("/ringbuf/power2", test_power2, NULL);
 	l_test_add("/ringbuf/alloc", test_alloc, NULL);
 	l_test_add("/ringbuf/printf", test_printf, NULL);
+	l_test_add("/ringbuf/append", test_append, NULL);
+	l_test_add("/ringbuf/append2", test_append2, NULL);
 =

 	return l_test_run();
-
 }
-- =

2.17.1

--===============8384448516471683128==--

