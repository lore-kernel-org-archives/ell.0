Content-Type: multipart/mixed; boundary="===============5361259798909474432=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 2/4] key: Consistently return errno from syscall wrappers
Date: Thu, 21 Jul 2016 14:23:44 -0700
Message-ID: <alpine.OSX.2.20.1607211417540.41353@mjmartin-mac01.local>
In-Reply-To: <57912E3F.2070203@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5361259798909474432==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

On Thu, 21 Jul 2016, Denis Kenzior wrote:

> On 07/20/2016 05:19 PM, Mat Martineau wrote:
>> ---
>>   ell/key.c | 43 ++++++++++++++++++++++++++++++++++++-------
>>   1 file changed, 36 insertions(+), 7 deletions(-)
>> =

>> diff --git a/ell/key.c b/ell/key.c
>> index 6117e31..60602f9 100644
>> --- a/ell/key.c
>> +++ b/ell/key.c
>> @@ -64,43 +64,72 @@ static const char * const key_type_names[] =3D {
>>   static long kernel_add_key(const char *type, const char *description,
>>   				const void *payload, size_t len, int32_t =

>> keyring)
>>   {
>> -	return syscall(__NR_add_key, type, description, payload, len, =

>> keyring);
>> +	long result;
>> +
>> +	result =3D syscall(__NR_add_key, type, description, payload, len,
>> +				keyring);
>> +
>> +	return result >=3D 0 ? result : -errno;
>>   }
>> =

>
> I get lots of errno undeclared errors after this patch
>
> Looks like #include <errno.h> is missing.

That's what I get for reordering them. There are no conflicts between this =

patch and the last two, just apply it some time after patch 3/4.

--
Mat Martineau
Intel OTC

--===============5361259798909474432==--

