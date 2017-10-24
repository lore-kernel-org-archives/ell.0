Content-Type: multipart/mixed; boundary="===============3661637645795319301=="
MIME-Version: 1.0
From: Othman, Ossama <ossama.othman@intel.com>
Subject: Is l_genl instance returned by l_genl_new() fully usable?
Date: Tue, 24 Oct 2017 10:13:54 -0700
Message-ID: <CAPyD+=CEfbATFiVO426Xs6ZvhfxQvOQCO3Hp2+d-8D0DMpKCzg@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3661637645795319301==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi,

While looking at ELL's generic netlink code, I noticed that l_genl_new() is
part of the public API but it's not clear if the returned struct l_genl
instance is fully usable since its pid field isn't set as in
l_genl_new_default(), and since there's is no way to set it afterward.
This could result in the underlying sockaddr_nl nl_pid field being
different from l_genl's pid field (zero in this case).  Is that correct?

Thanks,
-Ossama

--===============3661637645795319301==
Content-Type: text/html
MIME-Version: 1.0
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="attachment.html"

PGRpdiBkaXI9Imx0ciI+SGksPGRpdj48YnI+PC9kaXY+PGRpdj5XaGlsZSBsb29raW5nIGF0IEVM
TCYjMzk7cyBnZW5lcmljIG5ldGxpbmsgY29kZSwgSSBub3RpY2VkIHRoYXQgbF9nZW5sX25ldygp
IGlzIHBhcnQgb2YgdGhlIHB1YmxpYyBBUEkgYnV0IGl0JiMzOTtzIG5vdCBjbGVhciBpZiB0aGUg
cmV0dXJuZWQgc3RydWN0IGxfZ2VubCBpbnN0YW5jZSBpcyBmdWxseSB1c2FibGUgc2luY2UgaXRz
IHBpZCBmaWVsZCBpc24mIzM5O3Qgc2V0IGFzIGluIGxfZ2VubF9uZXdfZGVmYXVsdCgpLCBhbmQg
c2luY2UgdGhlcmUmIzM5O3MgaXMgbm8gd2F5IHRvIHNldCBpdCBhZnRlcndhcmQuwqAgVGhpcyBj
b3VsZCByZXN1bHQgaW4gdGhlIHVuZGVybHlpbmcgc29ja2FkZHJfbmwgbmxfcGlkIGZpZWxkIGJl
aW5nIGRpZmZlcmVudCBmcm9tIGxfZ2VubCYjMzk7cyBwaWQgZmllbGQgKHplcm8gaW4gdGhpcyBj
YXNlKS7CoCBJcyB0aGF0IGNvcnJlY3Q/PC9kaXY+PGRpdj48YnI+PC9kaXY+PGRpdj5UaGFua3Ms
PC9kaXY+PGRpdj4tT3NzYW1hPC9kaXY+PGRpdj48YnI+PC9kaXY+PC9kaXY+Cg==

--===============3661637645795319301==--

