Content-Type: multipart/mixed; boundary="===============3739764368775837015=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH v2 2/3] dbus: Add disconnect watch support
Date: Fri, 13 Feb 2015 09:05:33 -0600
Message-ID: <54DE12BD.7000403@gmail.com>
In-Reply-To: <1423837390.4196.34.camel@linux.intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============3739764368775837015==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Jukka,

On 02/13/2015 08:23 AM, Jukka Rissanen wrote:
> On pe, 2015-02-13 at 08:01 -0600, Denis Kenzior wrote:
>> Hi Jukka,
>>
>> <snip>
>>
>>   >>> +struct filter_data {
>>>>> +	struct l_dbus *dbus;
>>>>> +	l_dbus_message_func_t handle_func;
>>>>> +	l_dbus_watch_func_t connect_func;
>>>>> +	l_dbus_watch_func_t disconnect_func;
>>>>> +	char *name;
>>>>> +	char *owner;
>>>>
>>>> What is the exact difference between name and owner?  I don't see a
>>>> distinction...
>>>
>>> name is something like "org.foobar" and owner is ":1.101"
>>>
>>> User registers watch using a name and dbus-daemon sends its
>>> notifications about NameOwnerChanged signals using the owner format so
>>> we need to track both formats.
>>
>> Yes, but you don't actually handle that anywhere.  So I don't see a
>> distinction in the current code.  If this is TBD, then simply don't
>> include this and mention somewhere that only unique bus names are suppor=
ted.
>
> Hmm, owner and name are handled differently in the code. For example see
> the format_rule() function.
>

Then help me understand.  You have:

in format_rule you have:
+       offset =3D snprintf(rule, size, "type=3D'signal'");
+       sender =3D data->name ? : data->owner;
+
+       if (sender)
+               offset +=3D snprintf(rule + offset, size - offset,
+                               ",sender=3D'%s'", sender);

in filter_data_get you have:
+       if (sender) {
+               if (sender[0] =3D=3D ':')
+                       owner =3D sender;
+               else
+                       name =3D sender;
+       }

So why not replace everything by simply sender?  Right now none of this =

makes sense to me since you're not traking the well-known-name -> unique =

name mapping.

If you only support unique names, just say so and make the code reflect =

that.  Don't try to sneak code in that is part of some future =

functionality.  I'm not a mind reader.

Regards,
-Denis

--===============3739764368775837015==--

