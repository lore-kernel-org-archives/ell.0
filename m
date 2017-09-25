Content-Type: multipart/mixed; boundary="===============5317734334426071768=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 4/4] genl: Fix termination of name strings
Date: Mon, 25 Sep 2017 16:03:11 -0700
Message-ID: <alpine.OSX.2.21.1709251527000.10397@mjmartin-mac01.sea.intel.com>
In-Reply-To: <3f6b2a0a-6a49-5207-2651-9d3146b3f9ef@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5317734334426071768==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


Hi Denis -

On Mon, 25 Sep 2017, Denis Kenzior wrote:

> Hi Mat,
>
> On 09/22/2017 05:12 PM, Mat Martineau wrote:
>> The genl_mcast and l_genl_family structs both have name fields of length
>> GENL_NAMSIZ. They are expected to be null terminated strings, but
>> strncpy() was being misused and not terminating long names
>> correctly. Depending on the context, this would result in an
>> unterminated string being passed to strcmp() or a kernel warning.
>> ---
>>   ell/genl.c | 6 +++---
>>   1 file changed, 3 insertions(+), 3 deletions(-)
>> =

>> diff --git a/ell/genl.c b/ell/genl.c
>> index 0ab6c98..b41a174 100644
>> --- a/ell/genl.c
>> +++ b/ell/genl.c
>> @@ -156,7 +156,7 @@ static struct l_genl_family *family_alloc(struct l_g=
enl =

>> *genl,
>>   	family =3D l_new(struct l_genl_family, 1);
>>     	family->genl =3D genl;
>> -	strncpy(family->name, name, GENL_NAMSIZ);
>> +	l_strlcpy(family->name, name, GENL_NAMSIZ);
>
> It would seem that l_genl_family_new should sanitize the name.  There's n=
o =

> point in truncating a name silently and trying to use it afterwards just =
to =

> fail spectacularly anyway.

How about checking for truncation here in family_alloc using the return =

value of l_strlcpy? family_alloc could return NULL, and l_genl_family_new =

already knows what to do with that.

>
>>     	family->op_list =3D l_queue_new();
>>   	family->mcast_list =3D l_queue_new();
>> @@ -232,7 +232,7 @@ static void family_add_mcast(struct l_genl_family =

>> *family, const char *name,
>>     	mcast =3D l_new(struct genl_mcast, 1);
>>   -	strncpy(mcast->name, name, GENL_NAMSIZ);
>> +	l_strlcpy(mcast->name, name, GENL_NAMSIZ);
>>   	mcast->id =3D id;
>>   	mcast->users =3D 0;
>>   @@ -1047,7 +1047,7 @@ static void get_family_callback(struct l_genl_ms=
g =

>> *msg, void *user_data)
>>   			family->id =3D *((uint16_t *) data);
>>   			break;
>>   		case CTRL_ATTR_FAMILY_NAME:
>> -			strncpy(family->name, data, GENL_NAMSIZ);
>> +			l_strlcpy(family->name, data, GENL_NAMSIZ);
>>   			break;
>>   		case CTRL_ATTR_VERSION:
>>   			family->version =3D *((uint32_t *) data);
>> =

>
> The other two are not called with user input but get their values from th=
e =

> kernel, no?

Mostly (one use of family_add_mcast uses a hard-coded string). The current =

use of strncpy is incorrect no matter where the name comes from.

--
Mat Martineau
Intel OTC

--===============5317734334426071768==--

