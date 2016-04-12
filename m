Content-Type: multipart/mixed; boundary="===============4478282065566601035=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH v2 08/11] dbus: Fix the kdbus message encoding
Date: Wed, 13 Apr 2016 01:06:40 +0200
Message-ID: <CAOq732Jc1DNwv0s5akNApW8NP9AhhOLgioOpAsPrd9cxy5FF9A@mail.gmail.com>
In-Reply-To: <570D75D7.7000704@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============4478282065566601035==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 13 April 2016 at 00:25, Denis Kenzior <denkenz@gmail.com> wrote:
> On 04/12/2016 05:10 PM, Andrzej Zaborowski wrote:
>> Hmm true.  But the body is now enclosed in a variant, so what buffer
>> do you suggest to write that into and assign to item->ver.address?
>>
>
> This is actually a nasty issue with kdbus.  As you say, variant must be a
> single type, this is specified in DBus-1 Spec somewhere.  So if we are to
> enclose it in a variant like kdbus wants, then it either needs to be:
> 1. enclosed in '()'
> 2. special cased.
>
> You're doing 1, however won't this result in the message signature being
> different depending on the the transport being used?

Why?  If we assume that the message's signature is the type in the
variant witout the () I don't see any ambiguity there.

I didn't find a specific statement of that in the docs although
https://wiki.gnome.org/Projects/GLib/GDBus/Version2 does say:

"The body of the message is inside of the variant at the end. The body
must be a tuple. "

>
> Can we special case the building of this variant for gvariant based
> messages?  Similar to how we're generating the signature on the fly in the
> builder?

Is it worth it though, just to save a memcpy?

Best regards

--===============4478282065566601035==--

