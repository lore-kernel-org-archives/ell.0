Content-Type: multipart/mixed; boundary="===============5135003751046937110=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH v2 07/11] gvariant: Utility to build GVariant message out
 of header+body
Date: Wed, 13 Apr 2016 00:06:18 +0200
Message-ID: <CAOq732KwW=77E3tL6snMgZ5i3_TAJ16P6aiyyOrPBKXmZryLGA@mail.gmail.com>
In-Reply-To: <570D6C5A.9080502@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5135003751046937110==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On 12 April 2016 at 23:44, Denis Kenzior <denkenz@gmail.com> wrote:
> Hi Andrew,
>
>> +     out_buf[pos++] =3D 0;
>>
>> +       out_buf[pos++] =3D '(';
>> +       memcpy(out_buf + pos, signature, strlen(signature));
>> +       pos +=3D strlen(signature);
>> +       out_buf[pos++] =3D ')';
>
>
> Is this written down anywhere?  Why is the body enclosed in a structure?

Well, the message signature is not a single dbus type but a sequence
of types (possibly empty) and variant only accepts one dbus type so we
need a structure.

>
> Do we handle this structure in the parsing phase somewhere?  Can't seem to
> locate that.

In patch 04 in dbus_message_from_blob I believe the last
_gvariant_iter_enter_struct() handles that.

Best regards

--===============5135003751046937110==--

