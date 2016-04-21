Content-Type: multipart/mixed; boundary="===============5379055048938992901=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH v3 7/9] dbus: Remove signature field from gvariant header
Date: Fri, 22 Apr 2016 01:46:49 +0200
Message-ID: <CAOq732+tAB0jGwuHQN1LLmLM2y2ov-xGq0C4VHODKv=3xkBm5Q@mail.gmail.com>
In-Reply-To: <57151280.8010706@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5379055048938992901==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 18 April 2016 at 18:59, Denis Kenzior <denkenz@gmail.com> wrote:
> On 04/14/2016 07:34 PM, Andrew Zaborowski wrote:
>> -       l_free(generated_signature);
>> -
>>         build_header(message, signature);
>>         message->sealed =3D true;
>> -
>> -       get_header_field(message, DBUS_MESSAGE_FIELD_SIGNATURE, 'g',
>> -                                               &message->signature);
>> +       message->signature =3D generated_signature;
>
>
> Are you forgetting to set signature_free?

Oops, yes, I'll resend the patch.

Best regards

--===============5379055048938992901==--

