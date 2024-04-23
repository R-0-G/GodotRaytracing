using System;
using System.Collections.Generic;
using Godot;

public abstract partial class RogPlugin : EditorPlugin
{
    private Dictionary<EditorPlugin.CustomControlContainer, MenuButton> addedButtons = new Dictionary<CustomControlContainer,MenuButton>();
    private Dictionary<PopupMenu, Dictionary<long, Action>> actionMap = new Dictionary<PopupMenu, Dictionary<long, Action>>();
    private Dictionary<string, PopupMenu> aliasMap = new Dictionary<string, PopupMenu>();
    protected abstract string RootName { get;}
    protected void AddSpatialMenu(string path, Action callback = null)
    {
        MenuButton button = GetMenuButton(RootName, CustomControlContainer.SpatialEditorMenu);
        path = RootName + "/" + path;

        EnsurePopupMenusForPath(path);

        string parentPath = path.Substring(0, path.LastIndexOf('/'));
        string name = path.Substring(path.LastIndexOf('/')+1);

        if (aliasMap.TryGetValue(parentPath, out PopupMenu menu))
        {
            AddActionMap(menu, callback);
            menu.AddItem(name);
        }
    }

    private void AddActionMap(PopupMenu popupMenu, Action callback)
    {
        if (actionMap.TryGetValue(popupMenu, out Dictionary<long, Action> dict))
        {
            dict.Add(dict.Keys.Count, callback);
        }
        else
        {
            Dictionary<long,Action> newDict = new Dictionary<long, Action>();
            newDict.Add(0, callback);
            actionMap.Add(popupMenu, newDict );
        }

    }


    private void EnsurePopupMenusForPath(string path)
    {
        string[] paths = path.Split('/');
        string currentPath = "";
        for (int i=0; i<paths.Length-1; i++)
        {
            currentPath += paths[i];
            if (!aliasMap.TryGetValue(currentPath, out PopupMenu lowestMenu))
            {
                string parentPath = currentPath.Substring(0, currentPath.LastIndexOf('/'));
                string parentName = currentPath.Substring(currentPath.LastIndexOf('/')+1);
                string name = path.Substring(path.LastIndexOf('/')+1);
                
                PopupMenu newPop = new PopupMenu ();
                newPop.Name = parentName;
                aliasMap.Add(currentPath, newPop);
                newPop.IndexPressed += (x) => HandleIndex(newPop, x);

                aliasMap.TryGetValue(parentPath, out PopupMenu parentMenu);
                parentMenu.AddSubmenuItem(parentName,parentName);
                parentMenu.AddChild(newPop);
            }
            currentPath += "/";
        }
    }

    private void HandleIndex(PopupMenu newPop, long x)
    {
        if (actionMap.TryGetValue(newPop, out Dictionary<long, Action> val))
        {
            if (val.TryGetValue(x, out Action callback))
            {
                callback();
            }
        }
    }

    public override void _EnterTree()
    {
        addedButtons.Clear();
        base._EnterTree();
    }

    public override void _ExitTree()
    {
        foreach (KeyValuePair<EditorPlugin.CustomControlContainer,MenuButton> kvp in addedButtons)
        {
            RemoveControlFromContainer(kvp.Key, kvp.Value);
        }

        base._ExitTree();
    }

    public MenuButton GetMenuButton(string buttonName, EditorPlugin.CustomControlContainer container)
    {
        if (!addedButtons.ContainsKey(container))
        {
            MenuButton menuButton = new MenuButton();
            menuButton.Text = buttonName;
            menuButton.ToggleMode = true;
            aliasMap.Add(RootName, menuButton.GetPopup());
            AddControlToContainer(container, menuButton);
            addedButtons.Add(container, menuButton);
            PopupMenu root = menuButton.GetPopup();
            root.IndexPressed += (x) => HandleIndex(root, x);
            aliasMap.TryAdd(RootName, root);
            return menuButton;
        }

        return addedButtons[container];
    }
}