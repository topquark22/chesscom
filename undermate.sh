USERNAME=$1

if [ ! -d $USERNAME ]; then
  . ./chessdump.sh $USERNAME
fi

for f in ${GAMES_DIR}/${USERNAME}/*.json; do
  jq -r '
    .games[]
    | select(.pgn | test("=[nbr]#"; "i"))
    | .url
  ' "$f"
done
