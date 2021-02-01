function Track=reconstructTrack(TrackObj,Par)

for i=Par.i0:Par.Fr
    Track.ID{i}=Par.ID;
end

for id=Par.ID
    Track.Obj{id}=TrackObj{id};
    Track.Obj{id}.i0=Par.i0;
    Track.Obj{id}.ie=Par.Fr;
end

end