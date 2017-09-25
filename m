Content-Type: multipart/mixed; boundary="===============5128381583667027968=="
MIME-Version: 1.0
From: Mat Martineau <mathew.j.martineau@linux.intel.com>
Subject: Re: [PATCH 2/4] util: Add l_strlcpy
Date: Mon, 25 Sep 2017 15:18:21 -0700
Message-ID: <alpine.OSX.2.21.1709251505380.10397@mjmartin-mac01.sea.intel.com>
In-Reply-To: <721a0b90-2d17-c284-9bcd-4518a8ade096@gmail.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============5128381583667027968==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable


Hi Denis,

On Mon, 25 Sep 2017, Denis Kenzior wrote:

> Hi Mat,
>
> On 09/22/2017 05:12 PM, Mat Martineau wrote:
>> ---
>>   ell/util.c | 32 ++++++++++++++++++++++++++++++++
>>   ell/util.h |  2 ++
>>   2 files changed, 34 insertions(+)
>> =

>> diff --git a/ell/util.c b/ell/util.c
>> index 98916e5..2879f9f 100644
>> --- a/ell/util.c
>> +++ b/ell/util.c
>> @@ -443,6 +443,38 @@ LIB_EXPORT bool l_str_has_prefix(const char *str, =

>> const char *prefix)
>>   	return !strncmp(str, prefix, prefix_len);
>>   }
>>   +/**
>> + * l_strlcpy:
>> + * @dst: Destination buffer for string
>> + * @src: Source buffer containing null-terminated string to copy
>> + * @len: Maximum destination buffer space to use
>> + *
>> + * Copies a string from the @src buffer to the @dst buffer, using no
>> + * more than @len bytes in @dst. @dst is guaranteed to be
>> + * null-terminated. The caller can determine if the copy was truncated =
by
>> + * checking if the return value is greater than or equal to @len.
>> + *
>> + * Returns: The length of the @src string, not including the null
>> + * terminator.
>> + */
>> +LIB_EXPORT size_t l_strlcpy(char* dst, const char *src, size_t len)
>> +{
>> +	size_t src_len =3D strlen(src);
>> +
>> +	if (len) {
>> +		if (src_len < len) {
>> +			len =3D src_len + 1;
>> +		} else {
>> +			len -=3D 1;
>> +			dst[len] =3D '\0';
>> +		}
>> +
>> +		memcpy(dst, src, len);
>
> how does a direct for/while loop implementation compare speed wise to cal=
ling =

> strlen & memcpy?

It's about twice as fast to use strlen/memcpy. The direct =

implementation I used for comparison:

         const char *orig_src =3D src;

         if (len) {
                 while (*src !=3D '\0' && --len) {
                         *dst++ =3D *src++;
                 }
                 *dst =3D '\0';
         }
         return (src - orig_src) + strlen(src);

I modified the unit test to run a bunch of iterations with some more =

string sizes and to take performance samples during the strlcpy test. =

gperftools showed that the direct code spent 57.39% of execution time =

inside l_strlcpy and the strlen/memcpy technique spent 16.06% of execution =

time inside l_strlcpy. Turning off the profiling stuff and just using =

'time', direct took 53.973 seconds and strlen/memcpy took 25.176 seconds =

of user time.

>
>> +	}
>> +
>> +	return src_len;
>> +}
>> +
>>   /**
>>    * l_str_has_suffix:
>>    * @str: A string to be examined
>> diff --git a/ell/util.h b/ell/util.h
>> index a77c0b8..126a172 100644
>> --- a/ell/util.h
>> +++ b/ell/util.h
>> @@ -222,6 +222,8 @@ char *l_strjoinv(char **str_array, const char delim);
>>   bool l_str_has_prefix(const char *str, const char *prefix);
>>   bool l_str_has_suffix(const char *str, const char *suffix);
>>   +size_t l_strlcpy(char* dst, const char *src, size_t len);
>> +
>>   char *l_util_hexstring(const unsigned char *buf, size_t len);
>>   unsigned char *l_util_from_hexstring(const char *str, size_t *out_len);
>> =

>
> Regards,
> -Denis
>

--
Mat Martineau
Intel OTC

--===============5128381583667027968==--

