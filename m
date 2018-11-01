Content-Type: multipart/mixed; boundary="===============0464621848862365145=="
MIME-Version: 1.0
From: Denis Kenzior <denkenz@gmail.com>
Subject: Re: [PATCH 04/11] pem: Add l_pem_load_certificate_list utility
Date: Thu, 01 Nov 2018 14:40:50 -0500
Message-ID: <ab97fe67-0aab-e098-1e29-f5b5c0b2ad7c@gmail.com>
In-Reply-To: <20181101115453.10373-4-andrew.zaborowski@intel.com>
List-Id: <ell.lists.01.org>
To: ell@lists.01.org

--===============0464621848862365145==
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On 11/01/2018 06:54 AM, Andrew Zaborowski wrote:
> l_pem_load_certificate_list loads all the certificates in a file with
> multiple concatenated PEM structures.  This could also be done
> previously by calling l_pem_load_file with consecutive index values
> until it returned an error, this is a faster way to load all of the
> certificates.
> ---
>   ell/ell.sym |  1 +
>   ell/pem.c   | 84 +++++++++++++++++++++++++++++++++++++++++++++++++++--
>   ell/pem.h   |  8 +++++
>   3 files changed, 90 insertions(+), 3 deletions(-)
> =

> +static void pem_element_free(void *data)
> +{
> +	struct l_pem_list_element *element =3D data;
> +
> +	l_free(element->content);
> +	l_free(element);
> +}

So I see that we duplicate this free function a bunch of times in the =

later commits in this series.  Perhaps we should bite the bullet and =

make l_pem an actual first class object with some getters and a destructor.

E.g.

const void *l_pem_get_content(struct l_pem *);
size_t l_pem_get_content_length(struct l_pem *);

void l_pem_free(struct l_pem *);

and possibly:
enum l_pem_type l_pem_get_type(struct l_pem *);

> +
> +LIB_EXPORT struct l_queue *l_pem_load_certificate_list(const char *filen=
ame)
> +{
> +	int fd;
> +	struct stat st;
> +	uint8_t *data;
> +	size_t start =3D 0;
> +	struct l_queue *result =3D NULL;
> +
> +	fd =3D open(filename, O_RDONLY);
> +	if (fd < 0)
> +		return NULL;
> +
> +	if (fstat(fd, &st) < 0) {
> +		close(fd);
> +
> +		return NULL;
> +	}
> +
> +	data =3D mmap(NULL, st.st_size, PROT_READ, MAP_SHARED, fd, 0);
> +	if (data =3D=3D MAP_FAILED) {
> +		close(fd);
> +
> +		return NULL;
> +	}
> +
> +	while (1) {
> +		uint8_t *certificate;
> +		size_t len;
> +		char *label;
> +		struct l_pem_list_element *element;
> +		const uint8_t *end;
> +
> +		certificate =3D pem_load_buffer(data + start, st.st_size - start, 0,
> +						&label, &len, &end);
> +		if (!certificate)
> +			goto done;

I'm not so sure about this.  pem_load_buffer can fail for base64 decode =

failure reasons.  So I wouldn't think that you can assume that a failure =

means EOF + success.

> +
> +		if (strcmp(label, "CERTIFICATE")) {
> +			l_free(certificate);
> +			break;
> +		}
> +
> +		l_free(label);
> +		element =3D l_malloc(sizeof(struct l_pem_list_element));

l_new?

> +		element->content =3D certificate;
> +		element->len =3D len;
> +
> +		if (!result)
> +			result =3D l_queue_new();
> +
> +		l_queue_push_tail(result, element);
> +		start =3D end - data;

You really need serious mental gymnastics to get this part.  Can't we =

just have a curpos variable or something?

> +	}
> +
> +	/* Error occured */
> +	l_queue_destroy(result, pem_element_free);
> +	result =3D NULL;
> +
> +done:
> +	munmap(data, st.st_size);
> +	close(fd);
> +
> +	return result;
> +}
> +
>   /**
>    * l_pem_load_private_key
>    * @filename: path string to the PEM file to load
> diff --git a/ell/pem.h b/ell/pem.h
> index 93282a3..9cead5c 100644
> --- a/ell/pem.h
> +++ b/ell/pem.h
> @@ -27,12 +27,20 @@
>   extern "C" {
>   #endif
>   =

> +struct l_queue;
> +
> +struct l_pem_list_element {
> +	uint8_t *content;
> +	size_t len;
> +};
> +

As mentioned above, this probably should be a first class opaque data now.

>   uint8_t *l_pem_load_buffer(const uint8_t *buf, size_t buf_len,
>   				int index, char **type_label, size_t *out_len);

and we can change this to

struct l_pem *l_pem_load_buffer(buf, buf_len, index, char **);

I also really wonder if we want to take this function out of the public =

API, though we do need to add support for TPM 1.2 certificates as well.

>   uint8_t *l_pem_load_file(const char *filename, int index,
>   				char **type_label, size_t *len);
>   =

>   uint8_t *l_pem_load_certificate(const char *filename, size_t *len);
> +struct l_queue *l_pem_load_certificate_list(const char *filename);
>   =

>   uint8_t *l_pem_load_private_key(const char *filename, const char *passp=
hrase,
>   				bool *encrypted, size_t *len);
> =


Regards,
-Denis

--===============0464621848862365145==--

