Content-Type: multipart/mixed; boundary="===============0684391274027173582=="
MIME-Version: 1.0
From: Andrzej Zaborowski <andrew.zaborowski@intel.com>
Subject: Re: [PATCH 02/12] dbus: Validate field type in get_header_field
Date: Mon, 11 Apr 2016 22:06:19 +0200
Message-ID: <CAOq732Kmf1ktLcM8=tFwdD0iYrmGzuDSb+zFe74yM0P9M8B13A@mail.gmail.com>
In-Reply-To: <570C0268.3020301@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0684391274027173582==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Denis,

On 11 April 2016 at 22:00, Denis Kenzior <denkenz@gmail.com> wrote:
> Hi Andrew,
>
> On 04/09/2016 11:02 PM, Andrew Zaborowski wrote:
>>
>> It seems there's no place where we are validating the header
>> fields of incoming messages so let's do it here.
>> ---
>>   ell/dbus-message.c | 35 ++++++++++++++++++++---------------
>>   1 file changed, 20 insertions(+), 15 deletions(-)
>>
>> diff --git a/ell/dbus-message.c b/ell/dbus-message.c
>> index ece98a4..6e2831b 100644
>> --- a/ell/dbus-message.c
>> +++ b/ell/dbus-message.c
>> @@ -554,7 +554,8 @@ static inline bool message_iter_next_entry(struct
>> l_dbus_message_iter *iter,
>>   }
>>
>>   static bool get_header_field_from_iter_valist(struct l_dbus_message
>> *message,
>> -                                               uint8_t type, va_list
>> args)
>> +                                               uint8_t type, char
>> data_type,
>> +                                               va_list args)
>>   {
>>         struct l_dbus_message_iter header;
>>         struct l_dbus_message_iter array, iter;
>> @@ -591,6 +592,9 @@ static bool get_header_field_from_iter_valist(struct
>> l_dbus_message *message,
>>                 if (field_type !=3D type)
>>                         continue;
>>
>> +               if (iter.sig_start[iter->sig_pos] !=3D data_type)
>> +                       return false;
>> +
>
>
>   CC       ell/dbus-message.lo
> ell/dbus-message.c: In function =E2=80=98get_header_field_from_iter_valis=
t=E2=80=99:
> ell/dbus-message.c:595:26: error: invalid type argument of =E2=80=98->=E2=
=80=99 (have
> =E2=80=98struct l_dbus_message_iter=E2=80=99)
>    if (iter.sig_start[iter->sig_pos] !=3D data_type)
>                           ^
> Should that be iter.sig_pos?

Yes, unfortunately I did a poor job splitting my changes into patches
and the intermediate states don't compile, for example after this
patch 2 and after patch 4.  Note patches 4-5 also breaks something,
I'm going to resend them when I fix the issue.

Best regards

--===============0684391274027173582==--

