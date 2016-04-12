Content-Type: multipart/mixed; boundary="===============4694382338655786409=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 08/11] dbus: Fix the kdbus message encoding
Date: Tue, 12 Apr 2016 18:30:19 -0500
Message-ID: <570D850B.5060704@gmail.com>
In-Reply-To: <CAOq732+=aS_EtjWyOY5m0RDVBjgw7MwPwD27F5a1FoXi36QyKg@mail.gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4694382338655786409==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew

On 04/12/2016 06:11 PM, Andrzej Zaborowski wrote:
> On 13 April 2016 at 01:06, Andrzej Zaborowski
> <andrew.zaborowski@intel.com> wrote:
>> On 13 April 2016 at 00:25, Denis Kenzior <denkenz@gmail.com> wrote:
>>> Can we special case the building of this variant for gvariant based
>>> messages?  Similar to how we're generating the signature on the fly in =
the
>>> builder?
>>
>> Is it worth it though, just to save a memcpy?
>
> BTW we still need to add the offset after the variant, which is the
> header size, so it wouldn't save the memcpy.
>

Yikes, these people are more insane than I thought ;)

Why do they insist on:
"When transmitting over kdbus, the entire content of the header (all =

parts up to and including the extended header dictionary) must be =

transmitted inside of the first payload item (either vector or memfd). =

The content may be merged with the body (or part of the body) into the =

same item, but the entire header must appear entirely within the first =

item. "

If the actual field length is only known WAAAY later?

Anyway, can we add the offsets inside builder_finalize again.  Or =

alternatively as a separate KDBUS_ITEM?

Regards,
-Denis

--===============4694382338655786409==--

