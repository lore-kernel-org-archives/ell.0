Content-Type: multipart/mixed; boundary="===============7982803406415304493=="
MIME-Version: 1.0
From: Tomasz Bursztyka <tomasz.bursztyka@linux.intel.com>
Subject: Re: [PATCH 4/4] unit: Add a message builder unit test for genl
Date: Tue, 24 Mar 2015 08:55:48 +0200
Message-ID: <55110A74.8050500@linux.intel.com>
In-Reply-To: <71E450CF-79D0-422F-918C-58CD5C2EAA68@holtmann.org>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============7982803406415304493==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Marcel,

>> -#include <sys/socket.h>
>> +#include <assert.h>
>> +#include <linux/if_ether.h>
>> +#include <linux/nl80211.h>
> I rather not include nl80211.h from ELL.

Ok, so redefining the constants should be the way.

>> #include <ell/ell.h>
>> +#include <ell/genl-private.h>
>>
>> -static void do_debug(const char *str, void *user_data)
>> -{
>> -	const char *prefix =3D user_data;
>> +struct key_builder {
>> +	uint32_t index;
>> +	uint8_t key_index;
>> +	uint8_t mac[ETH_ALEN];
>> +	const char *tk;
>> +	size_t tk_len;
>> +	const char *rsc;
>> +	size_t rsc_len;
>> +	uint32_t cipher;
>> +	bool multicast;
>> +	const char *verification;
>> +	uint32_t verification_len;
>> +};
> I would really prefer if we are building generic tests data structures th=
at can be used here for adding many (read 20+) test cases instead of some c=
opied over from iwd.
>
> Unit tests should be generic and excerise every possible functionality. T=
hat way you can ensure that code works and keep ensuring that nobody accide=
ntally broke it.
>
> I mean you have unit/test-dbus-message.c as an example here. It has funct=
ions to build the message and a data structure to compare it again. That se=
ems to work pretty well so far. Why not do the same.

Ok

>> +int main(int argc, char *argv[])
>> +{
>> +	l_test_init(&argc, &argv);
>>
>> -	l_genl_unref(genl);
>> +	l_test_add("nested msg", test_genl_msg_builder, &nl80211_nested_key);
>> +	l_test_add("normal msg", test_genl_msg_builder, &nl80211_key);
>>
>> -	return 0;
>> +	return l_test_run();
>> }
> I really do not understand why you had to rewrite my test tool here and t=
ake the existing functionality out. There is no mentioning anywhere that th=
is can no longer be done. And if you would have followed the D-Bus examples=
 in ELL, then this looks more fitting with a new unit test like unit/test-g=
enl-msg.c or similar anyway.

Ok, I'll let test-genl.c alone. Looks like Denis did the test-genl-msg.c =

so I push the builder thing there.

Tomasz

--===============7982803406415304493==--

