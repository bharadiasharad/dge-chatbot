import { Controller, Get, Post, Put, Delete, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiSecurity } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

import { SessionsService } from './sessions.service';
import { CreateSessionDto, RenameSessionDto } from './dto';

@ApiTags('Sessions')
@Controller('sessions')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
@ApiSecurity('api-key')
export class SessionsController {
  constructor(private readonly sessionsService: SessionsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new session' })
  @ApiResponse({ status: 201, description: 'Session created successfully' })
  async create(@Body() body: CreateSessionDto, @Request() req) {
    return this.sessionsService.create(req.user.userId, body.title, body.description);
  }

  @Get()
  @ApiOperation({ summary: 'Get all sessions for user' })
  @ApiResponse({ status: 200, description: 'Sessions retrieved successfully' })
  async findAll(@Request() req) {
    return this.sessionsService.findAll(req.user.userId);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a specific session' })
  @ApiResponse({ status: 200, description: 'Session retrieved successfully' })
  @ApiResponse({ status: 404, description: 'Session not found' })
  async findOne(@Param('id') id: string, @Request() req) {
    return this.sessionsService.findOne(id, req.user.userId);
  }

  @Put(':id/rename')
  @ApiOperation({ summary: 'Rename a session' })
  @ApiResponse({ status: 200, description: 'Session renamed successfully' })
  async rename(@Param('id') id: string, @Body() body: RenameSessionDto, @Request() req) {
    return this.sessionsService.rename(id, req.user.userId, body.title);
  }

  @Put(':id/favorite')
  @ApiOperation({ summary: 'Toggle session favorite status' })
  @ApiResponse({ status: 200, description: 'Session favorite status updated' })
  async toggleFavorite(@Param('id') id: string, @Request() req) {
    return this.sessionsService.toggleFavorite(id, req.user.userId);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a session' })
  @ApiResponse({ status: 204, description: 'Session deleted successfully' })
  async remove(@Param('id') id: string, @Request() req) {
    await this.sessionsService.remove(id, req.user.userId);
  }
} 