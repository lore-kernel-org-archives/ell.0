Content-Type: multipart/mixed; boundary="===============6614575828595051021=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Re: ELL double free during  debug exit cleanup
Date: Tue, 05 Nov 2019 20:23:59 +0000
Message-ID: <8ee198b021f53f997e9359f910ca90c2f6bfd19b.camel@intel.com>
In-Reply-To: <4b68cc4c9fbaa9f7351d18449ab02f843c8340c6.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6614575828595051021==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

For what it's worth:

I created an x86_64 openSUSE tumbleweed VM, and GIT repos of the master tip=
 of both ELL and BLUEZ.

This appears to build and run correctly using that configuration.
The *reported* failure is using the BLUEZ tarball of 5.52, and sure enough =
if I do the *exact instructions* in
the bug report:
	> tar xf bluez-5.52.tar.xz
	> cd bluez-5.52
	> CFLAGS=3D"-flto=3Dauto" ./configure --enable-mesh
	> make check

I can reproduce the problem on openSUSE only (it fails much earlier, in unr=
elated areas if I try this on
Fedora-30).

A working patch to solve this problem looks like this (using l_* for new gl=
obal symbols):

diff --git a/ell/log.c b/ell/log.c
index f3f4b0c..a73aac1 100644
--- a/ell/log.c
+++ b/ell/log.c
@@ -441,7 +441,7 @@ LIB_EXPORT void l_debug_disable(void)
 	debug_pattern =3D NULL;
 }
 =

-__attribute__((constructor)) static void register_debug_section()
+__attribute__((constructor)) void l_register_debug_section()
 {
 	extern struct l_debug_desc __start___ell_debug[];
 	extern struct l_debug_desc __stop___ell_debug[];
@@ -449,7 +449,7 @@ __attribute__((constructor)) static void register_debug=
_section()
 	l_debug_add_section(__start___ell_debug, __stop___ell_debug);
 }
 =

-__attribute__((destructor(65535))) static void free_debug_sections()
+__attribute__((destructor(65535))) void l_free_debug_sections()
 {
 	l_queue_destroy(debug_sections, l_free);
 }
diff --git a/ell/log.h b/ell/log.h
index 19bf10b..04b913a 100644
--- a/ell/log.h
+++ b/ell/log.h
@@ -72,6 +72,8 @@ struct l_debug_desc {
 					__func__ , ##__VA_ARGS__); \
 } while (0)
 =

+void l_register_debug_section(void);
+void l_free_debug_sections(void);
 void l_debug_enable_full(const char *pattern,
 				struct l_debug_desc *start,
 				struct l_debug_desc *stop);


On Tue, 2019-11-05 at 16:22 +0000, Gix, Brian wrote:
> Hi Guys,
> =

> I am copying this over to the ELL reflector, hoping for some insight. The=
 new bluez-5.52 release has a unit
> test segfaulting in a test I added.  This only occurs on Link Time Optimi=
zation (LTO) builds, but that
> appears
> to be the favored build flavor of openSUSE.
> =

> The segfault occurs in the ELL code during exit, specifically due to a do=
uble call of:
> > l_queue_destroy(debug_sections, l_free);
> =

> Here is a bug report, that disects the problem, and suggests an ELL patch=
 (scroll down in the bug report to
> "Comment 6":
> =

> https://bugzilla.opensuse.org/show_bug.cgi?id=3D1155889#c6
> =

> I would like your opinion before creating a patch to submit.
> =

> Regards,
> Brian Gix
> _______________________________________________
> ell mailing list -- ell(a)lists.01.org
> To unsubscribe send an email to ell-leave(a)lists.01.org

--===============6614575828595051021==--

