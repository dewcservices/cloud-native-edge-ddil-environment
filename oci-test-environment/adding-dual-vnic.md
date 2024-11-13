1. Install oci CLI
https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm#InstallingCLI__oraclelinux8

```sh
sudo dnf install -y python36-oci-cli
```

```sh
oci setup config
```

2. install oci utils
https://docs.public.oneportal.content.oci.oraclecloud.com/en-us/iaas/oracle-linux/oci-utils/index.htm#oci-network-config__create_attach_vnic

```sh
sudo dnf install -y oci-utils
```

```sh
sudo vim /etc/oci-utils.conf.d/00-oci-utils.conf
```

update auth_method to 'proxy' and oci_sdk_user to '<username>' registered with oci cli
```
; How root can authenticate to OCI services.
;   auto   - detect a method that works
;   direct - use the root user's own .oci/config only
;   proxy  - use another user's .oci/config, see oci_sdk_user below
;   ip     - use instance principals
; auth_method = proxy
;
; Use the oci_sdk_user's OCI configuration to authenticate to OCI services.
; This user must have a valid SDK config file and the corresponding API key
; must be set up in the OCI Console.
; For more information about configuring the OCI Python SDK see:
; https://docs.us-phoenix-1.oraclecloud.com/Content/API/Concepts/sdkconfig.htm
; oci_sdk_user = <username>
```

2. add vnic

```sh
sudo oci-network-config attach-vnic -n name
```
