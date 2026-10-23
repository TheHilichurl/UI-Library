/**
 * ICON SYSTEM & ROBLOX ASSET ID MAPPER
 * Provides high-quality SVG vector icons for the Web UI
 * and verified Roblox rbxassetid:// mapping for generated Luau scripts.
 */

const ROBLOX_ICON_DATABASE = {
    // Navigation & Common
    'home': {
        svg: '<path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/>',
        rbxassetid: 'rbxassetid://6031097225',
        category: 'navigation'
    },
    'settings': {
        svg: '<path d="M12.22 2h-.44a2 2 0 0 0-2 2v.18a2 2 0 0 1-1 1.73l-.43.25a2 2 0 0 1-2 0l-.15-.08a2 2 0 0 0-2.73.73l-.22.38a2 2 0 0 0 .73 2.73l.15.1a2 2 0 0 1 1 1.72v.51a2 2 0 0 1-1 1.74l-.15.09a2 2 0 0 0-.73 2.73l.22.38a2 2 0 0 0 2.73.73l.15-.08a2 2 0 0 1 2 0l.43.25a2 2 0 0 1 1 1.73V20a2 2 0 0 0 2 2h.44a2 2 0 0 0 2-2v-.18a2 2 0 0 1 1-1.73l.43-.25a2 2 0 0 1 2 0l.15.08a2 2 0 0 0 2.73-.73l.22-.39a2 2 0 0 0-.73-2.73l-.15-.08a2 2 0 0 1-1-1.74v-.5a2 2 0 0 1 1-1.74l.15-.09a2 2 0 0 0 .73-2.73l-.22-.38a2 2 0 0 0-2.73-.73l-.15.08a2 2 0 0 1-2 0l-.43-.25a2 2 0 0 1-1-1.73V4a2 2 0 0 0-2-2z"/><circle cx="12" cy="12" r="3"/>',
        rbxassetid: 'rbxassetid://6031280882',
        category: 'navigation'
    },
    'user': {
        svg: '<path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>',
        rbxassetid: 'rbxassetid://6034287594',
        category: 'navigation'
    },
    'bell': {
        svg: '<path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/>',
        rbxassetid: 'rbxassetid://6031075931',
        category: 'common'
    },
    'sliders': {
        svg: '<line x1="4" x2="4" y1="21" y2="14"/><line x1="4" x2="4" y1="10" y2="3"/><line x1="12" x2="12" y1="21" y2="12"/><line x1="12" x2="12" y1="8" y2="3"/><line x1="20" x2="20" y1="21" y2="16"/><line x1="20" x2="20" y1="12" y2="3"/><line x1="1" x2="7" y1="14" y2="14"/><line x1="9" x2="15" y1="8" y2="8"/><line x1="17" x2="23" y1="16" y2="16"/>',
        rbxassetid: 'rbxassetid://6034684930',
        category: 'common'
    },
    'code': {
        svg: '<polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/>',
        rbxassetid: 'rbxassetid://6034509993',
        category: 'developer'
    },
    'terminal': {
        svg: '<polyline points="4 17 10 11 4 5"/><line x1="12" x2="20" y1="19" y2="19"/>',
        rbxassetid: 'rbxassetid://6034789852',
        category: 'developer'
    },
    'zap': {
        svg: '<polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>',
        rbxassetid: 'rbxassetid://6034261717',
        category: 'gaming'
    },
    'flame': {
        svg: '<path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.072-2.143-.224-4.054 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.153.433-2.294 1-3a2.5 2.5 0 0 0 2.5 2.5z"/>',
        rbxassetid: 'rbxassetid://6034510005',
        category: 'gaming'
    },
    'swords': {
        svg: '<polyline points="14.5 17.5 3 6 3 3 6 3 17.5 14.5"/><line x1="13" x2="19" y1="19" y2="13"/><line x1="16" x2="20" y1="16" y2="20"/><line x1="19" x2="21" y1="21" y2="19"/><polyline points="14.5 6.5 18 3 21 3 21 6 17.5 9.5"/><line x1="5" x2="11" y1="19" y2="13"/><line x1="4" x2="8" y1="16" y2="20"/><line x1="3" x2="5" y1="21" y2="19"/>',
        rbxassetid: 'rbxassetid://6034789871',
        category: 'gaming'
    },
    'shield': {
        svg: '<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>',
        rbxassetid: 'rbxassetid://6034684949',
        category: 'gaming'
    },
    'crown': {
        svg: '<path d="m2 4 3 12h14l3-12-6 7-4-7-4 7-6-7zm3 16h14"/>',
        rbxassetid: 'rbxassetid://6031075940',
        category: 'gaming'
    },
    'layers': {
        svg: '<polygon points="12 2 2 7 12 12 22 7 12 2"/><polyline points="2 17 12 22 22 17"/><polyline points="2 12 12 17 22 12"/>',
        rbxassetid: 'rbxassetid://6034510017',
        category: 'common'
    },
    'box': {
        svg: '<path d="M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z"/><path d="m3.3 7 8.7 5 8.7-5"/><path d="M12 22V12"/>',
        rbxassetid: 'rbxassetid://6031075955',
        category: 'common'
    },
    'crosshair': {
        svg: '<circle cx="12" cy="12" r="10"/><line x1="22" x2="18" y1="12" y2="12"/><line x1="6" x2="2" y1="12" y2="12"/><line x1="12" x2="12" y1="6" y2="2"/><line x1="12" x2="12" y1="22" y2="18"/>',
        rbxassetid: 'rbxassetid://6034261730',
        category: 'gaming'
    },
    'copy': {
        svg: '<rect width="14" height="14" x="8" y="8" rx="2" ry="2"/><path d="M4 16c-1.1 0-2-.9-2-2V4c0-1.1.9-2 2-2h10c1.1 0 2 .9 2 2"/>',
        rbxassetid: 'rbxassetid://6034509980',
        category: 'common'
    },
    'download': {
        svg: '<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" x2="12" y1="15" y2="3"/>',
        rbxassetid: 'rbxassetid://6034287606',
        category: 'common'
    },
    'check': {
        svg: '<polyline points="20 6 9 17 4 12"/>',
        rbxassetid: 'rbxassetid://6031094678',
        category: 'common'
    },
    'x': {
        svg: '<line x1="18" x2="6" y1="6" y2="18"/><line x1="6" x2="18" y1="6" y2="18"/>',
        rbxassetid: 'rbxassetid://6031094689',
        category: 'common'
    },
    'search': {
        svg: '<circle cx="11" cy="11" r="8"/><line x1="21" x2="16.65" y1="21" y2="16.65"/>',
        rbxassetid: 'rbxassetid://6031154871',
        category: 'common'
    },
    'palette': {
        svg: '<circle cx="13.5" cy="6.5" r=".5"/><circle cx="17.5" cy="10.5" r=".5"/><circle cx="8.5" cy="7.5" r=".5"/><circle cx="6.5" cy="12.5" r=".5"/><path d="M12 2C6.5 2 2 6.5 2 12s4.5 10 10 10c.926 0 1.648-.746 1.648-1.688 0-.437-.18-.835-.437-1.125-.29-.289-.438-.652-.438-1.125a1.64 1.64 0 0 1 1.668-1.668h1.996c3.051 0 5.555-2.503 5.555-5.554C21.965 6.012 17.461 2 12 2z"/>',
        rbxassetid: 'rbxassetid://6034684965',
        category: 'common'
    },
    'play': {
        svg: '<polygon points="5 3 19 12 5 21 5 3"/>',
        rbxassetid: 'rbxassetid://6034261745',
        category: 'common'
    },
    'refresh': {
        svg: '<path d="M3 12a9 9 0 0 1 9-9 9.75 9.75 0 0 1 6.74 2.74L21 8"/><path d="M21 3v5h-5"/><path d="M21 12a9 9 0 0 1-9 9 9.75 9.75 0 0 1-6.74-2.74L3 16"/><path d="M8 16H3v5"/>',
        rbxassetid: 'rbxassetid://6031280894',
        category: 'common'
    },
    'eye': {
        svg: '<path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/><circle cx="12" cy="12" r="3"/>',
        rbxassetid: 'rbxassetid://6034509971',
        category: 'common'
    },
    'info': {
        svg: '<circle cx="12" cy="12" r="10"/><line x1="12" x2="12" y1="16" y2="12"/><line x1="12" x2="12.01" y1="8" y2="8"/>',
        rbxassetid: 'rbxassetid://6031075968',
        category: 'common'
    },
    'alert-triangle': {
        svg: '<path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><line x1="12" x2="12" y1="9" y2="13"/><line x1="12" x2="12.01" y1="17" y2="17"/>',
        rbxassetid: 'rbxassetid://6031075979',
        category: 'common'
    },
    'sparkles': {
        svg: '<path d="m12 3-1.912 5.813a2 2 0 0 1-1.275 1.275L3 12l5.813 1.912a2 2 0 0 1 1.275 1.275L12 21l1.912-5.813a2 2 0 0 1 1.275-1.275L21 12l-5.813-1.912a2 2 0 0 1-1.275-1.275L12 3Z"/>',
        rbxassetid: 'rbxassetid://6034261762',
        category: 'gaming'
    },
    'key': {
        svg: '<path d="m21 2-2 2m-1.5 1.5L14 9l-2-2-4 4 2 2-3 3 2 2-3 3-2-2-2 2a4 4 0 1 1 5.66-5.66l3-3-2-2 4-4-2-2 3.5-3.5Z"/>',
        rbxassetid: 'rbxassetid://6034510033',
        category: 'common'
    }
};

/**
 * Render an SVG icon into an HTML string
 * @param {string} name - icon name
 * @param {number} size - size in px (default 18)
 * @param {string} className - optional CSS class
 */
function renderIcon(name, size = 18, className = '') {
    const iconData = ROBLOX_ICON_DATABASE[name] || ROBLOX_ICON_DATABASE['box'];
    return `<svg class="svg-icon ${className}" width="${size}" height="${size}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">${iconData.svg}</svg>`;
}

/**
 * Get Roblox Asset ID for an icon name
 * @param {string} name 
 * @returns {string} rbxassetid url
 */
function getRobloxIconAsset(name) {
    const iconData = ROBLOX_ICON_DATABASE[name] || ROBLOX_ICON_DATABASE['box'];
    return iconData.rbxassetid;
}

if (typeof module !== 'undefined' && module.exports) {
    module.exports = { ROBLOX_ICON_DATABASE, renderIcon, getRobloxIconAsset };
}
