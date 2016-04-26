Content-Type: multipart/mixed; boundary="===============6116720958107143818=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 2/5] gvariant: Allow empty signature in
 enter_struct_dict_common
Date: Tue, 26 Apr 2016 11:08:46 +0200
Message-ID: <CAOq732+1w9DSj2dtW1VMpZ19HUwzO_CCtA6q1oReAEZzsK34+A@mail.gmail.com>
In-Reply-To: <571EE80A.2040105@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============6116720958107143818==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 26 April 2016 at 06:01, Denis Kenzior <denkenz@gmail.com> wrote:
> Hi Andrew,
>
> On 04/22/2016 08:10 PM, Andrew Zaborowski wrote:
>>
>> gvariant_iter_init_internal now checks if the signature is empty before
>> calling _gvariant_num_children which would return an error in that case.
>> The gvariant_iter_init_internal caller is responsible for checking if
>> the signature is allowed in the specific context.
>> ---
>>   ell/gvariant-util.c | 16 +++++++++++-----
>>   1 file changed, 11 insertions(+), 5 deletions(-)
>>
>
> I went ahead an applied this one. But one question, what is the practical

Thanks

> utility of allowing iterators into the empty struct?

Well internally in ell we have a clear use case when we parse kdbus
messages, we use this to get the body start, body size and signature.
I also suspect the public function l_dbus_message_get_arguments makes
use of that when we're calling it with the empty signature to check
that the message signature is empty as expected.

Best regards

--===============6116720958107143818==--

