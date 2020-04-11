Content-Type: multipart/mixed; boundary="===============0184596471999099841=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: RFC: DBus send_with_reply wrapper doesn't time out
Date: Sat, 11 Apr 2020 20:55:10 +0000
Message-ID: <c0ed64f0-199a-60f1-3d95-4aa0be7a9e7f@gmail.com>
In-Reply-To: <51EC6F27-47B7-4AFB-A692-757E7C750154@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0184596471999099841==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Brian,

> It does, however, create the potential for at least a temporary resource =
leak. The hashmap gets saved for as long as it takes...   if we time out th=
e on the responde, is there anyway to tell ELL to cancel and cleanup the ha=
shmap?

That is what the destroy callback of l_dbus_send_with_reply is for.  The =

destroy callback gets called on userdata in all cases to free up any =

resources.

In the normal case it is called after the callback is invoked, but can =

also be called as a result of l_dbus_cancel, etc.

Regards,
-Denis
--===============0184596471999099841==--

