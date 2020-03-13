using System;
using UnityEngine;
using UnityEngine.UI;

/*
 * Copy/Paste script for InputField
 * Created by Egor Petrov 3.13.2020
 */

public class CopyPasteText : MonoBehaviour
{
    [SerializeField]
    private bool canCopy = true;
    [SerializeField]
    private bool canPaste = true;


    private InputField text;
    // Start is called before the first frame update
    void Start()
    {
        text = GetComponent<InputField>();
    }

    // Update is called once per frame
    void Update()
    {
        // GUIUtility.systemCopyBuffer didn't work on TVOS
#if !UNITY_TVOS
        if (Input.GetKeyDown(KeyCode.LeftControl) && Input.GetKeyDown(KeyCode.C) && canCopy)
        {
            Copy();
        }
        else
        {
            if (Input.GetKeyDown(KeyCode.LeftControl) && Input.GetKeyDown(KeyCode.V) && canPaste)
            {
                Paste();
            }
        }
#endif
    }
    Vector2Int GetPosition()
    {

        var res = new Vector2Int(0, 0);
        res.x = Math.Max(text.selectionAnchorPosition, text.selectionFocusPosition);
        res.y = Math.Min(text.selectionAnchorPosition, text.selectionFocusPosition);
        return res;
    }

    private void Paste()
    {
        string bufferedText = GUIUtility.systemCopyBuffer;
        if (!string.IsNullOrEmpty(bufferedText))
        {
            var selectedTextPosition = GetPosition();
            string source = text.text;
            if (Math.Abs(selectedTextPosition.x - selectedTextPosition.y) != 0)
            {
                source.Replace(source.Substring(selectedTextPosition.y, (selectedTextPosition.x - selectedTextPosition.y)), bufferedText);
            }
            else
            {
                source.Insert(selectedTextPosition.x, bufferedText);
            }
            text.text = source;
        }
    }

    private void Copy()
    {
        var selectedTextPosition = GetPosition();
        string source = text.text;
        string textToCopy = source;
        if (Math.Abs(selectedTextPosition.x - selectedTextPosition.y) != 0)
        {
            textToCopy = source.Substring(selectedTextPosition.y, (selectedTextPosition.x - selectedTextPosition.y));
        }

        GUIUtility.systemCopyBuffer = textToCopy;
    }
}
