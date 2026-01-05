def post_process_speaker_assignment(segments, min_words_threshold=3):
    """
    Sửa lỗi speaker khi chuyển lượt nói nhanh
    """
    corrected = []
    for seg in segments:
        words = seg.get("words", [])
        if not words:
            corrected.append(seg)
            continue
            
        first_speakers = [w["speaker"] for w in words[:min_words_threshold] if "speaker" in w]
        if not first_speakers:
            corrected.append(seg)
            continue
            
        dominant_first = max(set(first_speakers), key=first_speakers.count)
        current_speaker = seg["speaker"]
        
        if dominant_first != current_speaker and first_speakers.count(dominant_first) >= 1:
            new_seg = seg.copy()
            new_seg["speaker"] = dominant_first
            if "words" in new_seg:
                for w in new_seg["words"]:
                    if "speaker" in w:
                        w["speaker"] = dominant_first
            corrected.append(new_seg)
        else:
            corrected.append(seg)
            
    return corrected