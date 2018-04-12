
image_dir=$1
image_name=$2
registry_url=$3
token=$4
tag_name=$5

newlineIFS=$'\n'
layersFs="$(cat ${image_dir}/manifest.json | jq --raw-output --compact-output '.[] | .Layers[]')"
IFS="$newlineIFS"
layers=( $layersFs )
unset IFS
	
all_layers=()

for i in "${!layers[@]}"; do
	layerMeta="${layers[$i]}"
	echo "layerMeta $layerMeta"	
	size=$(wc -c ${image_dir}/${layerMeta} | awk '{print $1}')
	digest="sha256:$(shasum -a 256 ${image_dir}/${layerMeta} | cut -d' ' -f1)"
	
	echo "size $size"
	echo "digest $digest"
	
	all_layers+=("{\"mediaType\": \"application/vnd.docker.image.rootfs.diff.tar.gzip\",\"size\": $size,\"digest\": \"$digest\"}")
	
	# Check to see if the layer exists:
	returncode=$(curl -k -w "%{http_code}" \
				-o /dev/null \
				-I -H "Authorization: Bearer ${token}" \
				${registry_url}/${image_name}/blobs/$digest)

	echo "returncode $returncode"

	if [[ $returncode -ne 200  ]]; then
		location=$(curl -k -i -X POST \
				   ${registry_url}/${image_name}/blobs/uploads/ \
				   -H "Authorization: Bearer ${token}" \
				   -d "" | grep location | cut -d" " -f2 | tr -d '\r')
			   
		echo "location $location"
	
		# Do the upload
		curl --progress-bar -k -X PUT $location\&digest=$digest \
			-H "Authorization: Bearer ${token}" \
			-H "Content-Type: application/octet-stream" \
			--data-binary @${image_dir}/${layerMeta}
	fi

done

config_file=$(find ${image_dir} -regex ".*/[a-f0-9\-]\{64\}\.json")

config_size=$(wc -c ${config_file} | awk '{print $1}')
config_digest="sha256:$(shasum -a 256 ${config_file} | cut -d' ' -f1)"

echo "config_digest $config_digest"
# config
returncode=$(curl -k -w "%{http_code}" -o /dev/null \
    		-I -H "Authorization: Bearer ${token}" \
    		${registry_url}/${image_name}/blobs/$config_digest)

echo "returncode $returncode"

if [[ $returncode -ne 200  ]]; then
    # Start the upload and get the location header.
    # The HTTP response seems to include carriage returns, which we need to strip
    location=$(curl -k -i -X POST \
               ${registry_url}/${image_name}/blobs/uploads/ \
               -H "Authorization: Bearer ${token}" \
               -d "" | grep location | cut -d" " -f2 | tr -d '\r')

	echo "location $location"
		
    # Do the upload
    curl -k -X PUT $location\&digest=$config_digest \
        -H "Authorization: Bearer ${token}" \
		-H "Content-Type: application/json" \
        --data-binary @${config_file}
fi

all_layers_json_array=$(echo '[]' | jq --raw-output ".$(for layer in "${all_layers[@]}"; do echo " + [ $layer ]"; done)")


# We need to know the size and digest of our layer and config:

cat << EOF > manifest.json
{
  "schemaVersion": 2,
  "mediaType": "application/vnd.docker.distribution.manifest.v2+json",
  "config": {
    "mediaType": "application/vnd.docker.container.image.v1+json",
    "size": $config_size,
    "digest": "$config_digest"
  },
  "layers": $all_layers_json_array
}
EOF

cat manifest.json | jq

curl -k -X PUT \
    ${registry_url}/${image_name}/manifests/${tag_name} \
    -H "Authorization: Bearer ${token}" \
    -H 'Content-Type: application/vnd.docker.distribution.manifest.v2+json' \
    --data-binary @manifest.json
    
curl -k -X GET \
    ${registry_url}/${image_name}/manifests/${tag_name} \
    -H "Authorization: Bearer ${token}" -o manifest_v1.json
    
cat manifest_v1.json | jq

curl -k -X PUT \
    ${registry_url}/${image_name}/manifests/${tag_name} \
    -H "Authorization: Bearer ${token}" \
    -H 'Content-Type: application/vnd.docker.distribution.manifest.v1+json' \
    --data-binary @manifest_v1.json

