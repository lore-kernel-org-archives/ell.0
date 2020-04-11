Content-Type: multipart/mixed; boundary="===============3517282706529873440=="
MIME-Version: 1.0
From: Gix, Brian <brian.gix@intel.com>
Subject: Re: RFC: DBus send_with_reply wrapper doesn't time out
Date: Sat, 11 Apr 2020 17:46:59 +0000
Message-ID: <51EC6F27-47B7-4AFB-A692-757E7C750154@intel.com>
In-Reply-To: <93b7f2b0-3c61-ae78-daff-22505557b159@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3517282706529873440==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Thanks Denis,

> On Apr 11, 2020, at 9:00 AM, Denis Kenzior <denkenz@gmail.com> wrote:
> =

> =EF=BB=BFHi Brian,
> =

>> Is timing out reply required methods the dbus daemon responsibility?  Is=
 it the l_dbus_send_with_reply()
>> responsibility?  The mesh daemon responsibility?  Ideally, the App just =
responds, but we have no control over
>> how Apps respond to method calls.
> =

> Timeouts do not exist at the protocol level, their implementation is pure=
ly a higher level feature.
> =

> dbus-daemon can be configured to limit the maximum time an application ca=
n take to respond, but the default reply_timeout is set to -1 (infinite).
> =

> ell does not enable or enforce any timeouts for dbus method calls. Starti=
ng a timer for each dbus call is quite expensive, so for now we have left t=
his up to the application to manage.

I suspect this is what we need to do... we have perhaps just the one method=
 that absolutely requires this time-out, so I agree that pushing this into =
all =E2=80=9Csend-with-reply=E2=80=9D calls might be overkill.

It does, however, create the potential for at least a temporary resource le=
ak. The hashmap gets saved for as long as it takes...   if we time out the =
on the responde, is there anyway to tell ELL to cancel and cleanup the hash=
map?

> =

> Regards,
> -Denis

--===============3517282706529873440==--

