Content-Type: multipart/mixed; boundary="===============0553412575514535074=="
MIME-Version: 1.0
From: Jukka Rissanen <jukka.rissanen@linux.intel.com>
Subject: [PATCH 1/2] util: Add l_memdup function for allocation and copying a
 memory buffer
Date: Fri, 16 Jan 2015 11:13:51 +0200
Message-ID: <1421399632-19544-2-git-send-email-jukka.rissanen@linux.intel.com>
In-Reply-To: <1421399632-19544-1-git-send-email-jukka.rissanen@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0553412575514535074==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

---
 ell/util.c | 23 +++++++++++++++++++++++
 ell/util.h |  2 ++
 2 files changed, 25 insertions(+)

diff --git a/ell/util.c b/ell/util.c
index 97e70bc..3bf2e5d 100644
--- a/ell/util.c
+++ b/ell/util.c
@@ -103,6 +103,29 @@ LIB_EXPORT void *l_realloc(void *mem, size_t size)
 }
 =

 /**
+ * l_memdup:
+ * @mem: pointer to memory you want to duplicate
+ * @size: memory size
+ *
+ * If for any reason the memory allocation fails, then execution will be
+ * halted via abort().
+ *
+ * In case @size is 0 then #NULL will be returned.
+ *
+ * Returns: pointer to duplicated memory buffer
+ **/
+LIB_EXPORT void *l_memdup(const void *mem, size_t size)
+{
+	void *ptr;
+
+	ptr =3D l_malloc(size);
+	if (ptr)
+		memcpy(ptr, mem, size);
+
+	return ptr;
+}
+
+/**
  * l_free:
  * @ptr: memory pointer
  *
diff --git a/ell/util.h b/ell/util.h
index e4d674c..89000aa 100644
--- a/ell/util.h
+++ b/ell/util.h
@@ -157,6 +157,8 @@ static inline void l_put_be64(uint64_t val, void *dst)
 #define L_ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
 =

 void *l_malloc(size_t size) __attribute__ ((warn_unused_result, malloc));
+void *l_memdup(const void *mem, size_t size)
+			__attribute__ ((warn_unused_result, malloc));
 void l_free(void *ptr);
 =

 void *l_realloc(void *mem, size_t size)
-- =

1.8.3.1


--===============0553412575514535074==--

