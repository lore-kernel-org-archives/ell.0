Content-Type: multipart/mixed; boundary="===============4086051040567540992=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH v2 08/11] dbus: Fix the kdbus message encoding
Date: Wed, 13 Apr 2016 01:11:18 +0200
Message-ID: <CAOq732+=aS_EtjWyOY5m0RDVBjgw7MwPwD27F5a1FoXi36QyKg@mail.gmail.com>
In-Reply-To: <CAOq732Jc1DNwv0s5akNApW8NP9AhhOLgioOpAsPrd9cxy5FF9A@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4086051040567540992==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 13 April 2016 at 01:06, Andrzej Zaborowski
<andrew.zaborowski@intel.com> wrote:
> On 13 April 2016 at 00:25, Denis Kenzior <denkenz@gmail.com> wrote:
>> Can we special case the building of this variant for gvariant based
>> messages?  Similar to how we're generating the signature on the fly in t=
he
>> builder?
>
> Is it worth it though, just to save a memcpy?

BTW we still need to add the offset after the variant, which is the
header size, so it wouldn't save the memcpy.

Best regards

--===============4086051040567540992==--

