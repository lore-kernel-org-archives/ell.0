Content-Type: multipart/mixed; boundary="===============7708877316795935401=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: ELL double free during  debug exit cleanup
Date: Tue, 05 Nov 2019 16:22:48 +0000
Message-ID: <4b68cc4c9fbaa9f7351d18449ab02f843c8340c6.camel@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7708877316795935401==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Guys,

I am copying this over to the ELL reflector, hoping for some insight. The n=
ew bluez-5.52 release has a unit
test segfaulting in a test I added.  This only occurs on Link Time Optimiza=
tion (LTO) builds, but that appears
to be the favored build flavor of openSUSE.

The segfault occurs in the ELL code during exit, specifically due to a doub=
le call of:
> l_queue_destroy(debug_sections, l_free);

Here is a bug report, that disects the problem, and suggests an ELL patch (=
scroll down in the bug report to
"Comment 6":

https://bugzilla.opensuse.org/show_bug.cgi?id=3D1155889#c6

I would like your opinion before creating a patch to submit.

Regards,
Brian Gix

--===============7708877316795935401==--

