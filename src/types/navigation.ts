/**
 * Navigation type definitions
 * Used by Navbar and navigation data files
 * Supports audience-based mega dropdown menus
 */

export interface NavItem {
  name: string
  path: string
  external?: boolean
  /** Short description shown below the name in mega dropdown */
  desc?: string
  /** Icon identifier for SVG icon lookup */
  icon?: string
}

export interface NavFooterLink {
  name: string
  path: string
  external?: boolean
}

export interface NavDropdownItem extends NavItem {
  children?: NavItem[]
  /** Bottom link in dropdown panel (e.g. "View all solutions") */
  footerLink?: NavFooterLink
  /** Industry solution tags shown in dropdown (for business audience) */
  solutionTags?: string[]
}
